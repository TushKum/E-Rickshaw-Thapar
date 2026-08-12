import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, deleteDoc, collection, getDocs } from 'firebase/firestore';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const RULES = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'firestore.rules');

const PROJECT = 'demo-erickshaw';
const DRIVER = 'driver_alice';
const PASSENGER = 'passenger_bob';
const OTHER_PASSENGER = 'passenger_carol';
const NOBODY = 'randomer_dave'; // signed in, but no profile document

const testEnv = await initializeTestEnvironment({
  projectId: PROJECT,
  firestore: {
    rules: readFileSync(RULES, 'utf8'),
    host: '127.0.0.1',
    port: 8080,
  },
});

const REQ = { from: 'Main Gate', to: 'Central Library', pending: '0', driver_uid: '' };

// Seed profiles and a fresh open request, bypassing rules.
async function reset() {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'drivers', DRIVER), { name: 'Alice', type: 'driver' });
    await setDoc(doc(db, 'passengers', PASSENGER), { name: 'Bob', type: 'passenger' });
    await setDoc(doc(db, 'passengers', OTHER_PASSENGER), { name: 'Carol', type: 'passenger' });
    await setDoc(doc(db, 'requests', PASSENGER), REQ);
  });
}

const db = (uid) => testEnv.authenticatedContext(uid).firestore();

let pass = 0, fail = 0;
async function check(name, fn) {
  await reset();
  try {
    await fn();
    console.log(`  PASS  ${name}`);
    pass++;
  } catch (e) {
    console.log(`  FAIL  ${name}\n          ${String(e).split('\n')[0]}`);
    fail++;
  }
}

console.log('\n--- legitimate flows must still work ---');

await check('passenger opens their own request', () =>
  assertSucceeds(setDoc(doc(db(OTHER_PASSENGER), 'requests', OTHER_PASSENGER), REQ)));

await check('passenger reads their own request (polling for accept)', () =>
  assertSucceeds(getDoc(doc(db(PASSENGER), 'requests', PASSENGER))));

await check('driver lists every open request', () =>
  assertSucceeds(getDocs(collection(db(DRIVER), 'requests'))));

await check('driver accepts, stamping their own uid', () =>
  assertSucceeds(setDoc(doc(db(DRIVER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: DRIVER })));

await check('passenger cancels their own request', () =>
  assertSucceeds(deleteDoc(doc(db(PASSENGER), 'requests', PASSENGER))));

await check('driver reads passenger profile after matching', () =>
  assertSucceeds(getDoc(doc(db(DRIVER), 'passengers', PASSENGER))));

await check('passenger reads driver profile after matching', () =>
  assertSucceeds(getDoc(doc(db(PASSENGER), 'drivers', DRIVER))));

console.log('\n--- the hole this change closes ---');

await check('non-driver CANNOT accept a ride', () =>
  assertFails(setDoc(doc(db(NOBODY), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: NOBODY })));

await check('another passenger CANNOT accept a ride', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: OTHER_PASSENGER })));

await check('another passenger CANNOT delete someone else\'s request', () =>
  assertFails(deleteDoc(doc(db(OTHER_PASSENGER), 'requests', PASSENGER))));

await check('driver CANNOT delete a request', () =>
  assertFails(deleteDoc(doc(db(DRIVER), 'requests', PASSENGER))));

console.log('\n--- driver cannot cheat while accepting ---');

await check('driver CANNOT stamp a different driver\'s uid', () =>
  assertFails(setDoc(doc(db(DRIVER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: 'some_other_driver' })));

await check('driver CANNOT rewrite the route while accepting', () =>
  assertFails(setDoc(doc(db(DRIVER), 'requests', PASSENGER),
    { from: 'Chatter', to: 'Cosmo Hostel', pending: '1', driver_uid: DRIVER })));

await check('driver CANNOT re-accept an already-accepted ride', async () => {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'requests', PASSENGER),
      { ...REQ, pending: '1', driver_uid: 'first_driver' });
  });
  await assertFails(setDoc(doc(db(DRIVER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: DRIVER }));
});

console.log('\n--- request shape is enforced ---');

await check('passenger CANNOT open a pre-accepted request', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', OTHER_PASSENGER),
    { ...REQ, pending: '1', driver_uid: DRIVER })));

await check('passenger CANNOT open a request under another uid', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', PASSENGER), REQ)));

await check('CANNOT create a request with identical from/to', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', OTHER_PASSENGER),
    { ...REQ, from: 'Main Gate', to: 'Main Gate' })));

await check('CANNOT smuggle extra fields into a request', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', OTHER_PASSENGER),
    { ...REQ, fare: 0, admin: true })));

console.log('\n--- profiles are owner-only ---');

await check('CANNOT forge another user\'s driver profile', () =>
  assertFails(setDoc(doc(db(NOBODY), 'drivers', DRIVER), { name: 'Impostor' })));

await check('CANNOT self-register as a driver under someone else\'s uid', () =>
  assertFails(setDoc(doc(db(PASSENGER), 'drivers', DRIVER), { name: 'Bob' })));

await check('unauthenticated user CANNOT read requests', () =>
  assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'requests', PASSENGER))));

await testEnv.cleanup();
console.log(`\n${pass} passed, ${fail} failed\n`);
process.exit(fail === 0 ? 0 : 1);

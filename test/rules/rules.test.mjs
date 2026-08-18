import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, getDoc, deleteDoc, collection, getDocs, query, where,
} from 'firebase/firestore';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const RULES = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'firestore.rules');

const PROJECT = 'demo-erickshaw';
const DRIVER = 'driver_alice';
const PASSENGER = 'passenger_bob';
const OTHER_PASSENGER = 'passenger_carol';
const NOBODY = 'randomer_dave';       // signed in, but no profile document
const OUTSIDER = 'outsider_erin';     // signed in with a non-campus address

const testEnv = await initializeTestEnvironment({
  projectId: PROJECT,
  firestore: { rules: readFileSync(RULES, 'utf8'), host: '127.0.0.1', port: 8080 },
});

const REQ = { from: 'Main Gate', to: 'Central Library', pending: '0', driver_uid: '' };

// Token claims matter now: passenger writes are gated on a @thapar.edu address
// and ride actions on a confirmed one. Drivers are deliberately exempt from the
// domain rule — real rickshaw drivers have no institute address.
const CLAIMS = {
  [PASSENGER]:       { email: 'bob@thapar.edu',      email_verified: true },
  [OTHER_PASSENGER]: { email: 'carol@thapar.edu',    email_verified: true },
  [DRIVER]:          { email: 'alice@gmail.com',     email_verified: true },
  [NOBODY]:          { email: 'dave@thapar.edu',     email_verified: true },
  [OUTSIDER]:        { email: 'erin@gmail.com',      email_verified: true },
};

const db = (uid, overrides = {}) =>
  testEnv.authenticatedContext(uid, { ...CLAIMS[uid], ...overrides }).firestore();

async function reset() {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    await setDoc(doc(d, 'drivers', DRIVER), { name: 'Alice', type: 'driver' });
    await setDoc(doc(d, 'passengers', PASSENGER), { name: 'Bob', type: 'passenger' });
    await setDoc(doc(d, 'passengers', OTHER_PASSENGER), { name: 'Carol', type: 'passenger' });
    await setDoc(doc(d, 'requests', PASSENGER), REQ);
  });
}

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

await check('passenger reads their own request', () =>
  assertSucceeds(getDoc(doc(db(PASSENGER), 'requests', PASSENGER))));

await check('driver lists every open request', () =>
  assertSucceeds(getDocs(collection(db(DRIVER), 'requests'))));

await check('driver runs the filtered open-requests query', () =>
  assertSucceeds(getDocs(
    query(collection(db(DRIVER), 'requests'), where('pending', '==', '0')))));

await check('non-driver CANNOT run that query', () =>
  assertFails(getDocs(
    query(collection(db(NOBODY), 'requests'), where('pending', '==', '0')))));

await check('driver accepts, stamping their own uid', () =>
  assertSucceeds(setDoc(doc(db(DRIVER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: DRIVER })));

await check('passenger cancels their own request', () =>
  assertSucceeds(deleteDoc(doc(db(PASSENGER), 'requests', PASSENGER))));

await check('driver reads passenger profile after matching', () =>
  assertSucceeds(getDoc(doc(db(DRIVER), 'passengers', PASSENGER))));

await check('passenger reads driver profile after matching', () =>
  assertSucceeds(getDoc(doc(db(PASSENGER), 'drivers', DRIVER))));

console.log('\n--- campus email restriction (passengers only) ---');

await check('student signs up with a @thapar.edu address', () =>
  assertSucceeds(setDoc(doc(db(NOBODY), 'passengers', NOBODY),
    { name: 'Dave', type: 'passenger' })));

await check('outsider CANNOT create a passenger profile', () =>
  assertFails(setDoc(doc(db(OUTSIDER), 'passengers', OUTSIDER),
    { name: 'Erin', type: 'passenger' })));

await check('lookalike domain CANNOT create a passenger profile', () =>
  assertFails(setDoc(
    doc(db(OUTSIDER, { email: 'erin@thapar.edu.evil.com' }), 'passengers', OUTSIDER),
    { name: 'Erin', type: 'passenger' })));

await check('an account with no email claim CANNOT create one', () =>
  assertFails(setDoc(
    doc(db(OUTSIDER, { email: null }), 'passengers', OUTSIDER),
    { name: 'Erin', type: 'passenger' })));

await check('drivers are exempt — non-campus address still registers', () =>
  assertSucceeds(setDoc(doc(db(OUTSIDER), 'drivers', OUTSIDER),
    { name: 'Erin', type: 'driver' })));

console.log('\n--- confirmed address required to ride ---');

await check('unverified passenger CANNOT open a request', () =>
  assertFails(setDoc(
    doc(db(OTHER_PASSENGER, { email_verified: false }), 'requests', OTHER_PASSENGER),
    REQ)));

await check('unverified driver CANNOT accept a ride', () =>
  assertFails(setDoc(
    doc(db(DRIVER, { email_verified: false }), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: DRIVER })));

console.log('\n--- the driver role check ---');

await check('non-driver CANNOT accept a ride', () =>
  assertFails(setDoc(doc(db(NOBODY), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: NOBODY })));

await check('another passenger CANNOT accept a ride', () =>
  assertFails(setDoc(doc(db(OTHER_PASSENGER), 'requests', PASSENGER),
    { ...REQ, pending: '1', driver_uid: OTHER_PASSENGER })));

await check("another passenger CANNOT delete someone else's request", () =>
  assertFails(deleteDoc(doc(db(OTHER_PASSENGER), 'requests', PASSENGER))));

await check('driver CANNOT delete a request', () =>
  assertFails(deleteDoc(doc(db(DRIVER), 'requests', PASSENGER))));

console.log('\n--- driver cannot cheat while accepting ---');

await check("driver CANNOT stamp a different driver's uid", () =>
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

await check("CANNOT forge another user's driver profile", () =>
  assertFails(setDoc(doc(db(NOBODY), 'drivers', DRIVER), { name: 'Impostor' })));

await check("CANNOT self-register as a driver under someone else's uid", () =>
  assertFails(setDoc(doc(db(PASSENGER), 'drivers', DRIVER), { name: 'Bob' })));

await check('unauthenticated user CANNOT read requests', () =>
  assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'requests', PASSENGER))));

await testEnv.cleanup();
console.log(`\n${pass} passed, ${fail} failed\n`);
process.exit(fail === 0 ? 0 : 1);

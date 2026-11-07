// StreetPatch routes: filled in Chapter 25.
'use strict';
async function handle(req, res, route, query, h) {
  return h.send(res, 404, { error: 'Not found.' });
}
module.exports = { handle };

const uuid = require("uuidv4");

function unknownId(userContext, events, done) {
  userContext.vars.unknownId = uuid.uuid();
  return done();
}

module.exports = {
  unknownId
};
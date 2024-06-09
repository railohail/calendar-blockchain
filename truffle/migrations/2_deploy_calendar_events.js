const CalendarEvents = artifacts.require('MyContract')

module.exports = function (deployer) {
  deployer.deploy(CalendarEvents)
}

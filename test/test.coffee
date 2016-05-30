Helper = require("hubot-test-helper")
expect = require("chai").expect
proxyquire = require("proxyquire")
siiStub =
  byLastInvoice: (user, work) ->
    return new Promise (resolve, reject) ->
      expect(user.rut).to.equal('11111111-1')
      expect(user.password).to.eql('password')
      expect(work.value).to.eql(55556)
      resolve()
proxyquire("./../src/script.coffee", {sii: siiStub})

helper = new Helper("./../src/index.coffee")

describe "hubot-sii", ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context "valid", ->
    beforeEach (done) ->
      room.user.say("user", "hubot sii boleta 11.111.111-1 password 50000")
      setTimeout(done, 100)

    it "should reply", ->
      expect(room.messages).to.eql([
        ["user", "hubot sii boleta 11.111.111-1 password 50000"]
        ["hubot", "Boleta enviada"]
      ])

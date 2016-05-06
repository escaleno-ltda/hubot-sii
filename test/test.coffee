Helper = require("hubot-test-helper")
expect = require("chai").expect

helper = new Helper("./../src/index.coffee")

describe "hubot-sii", ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context "test", ->
    beforeEach (done) ->
      room.user.say("user", "hubot hubot-sii")
      setTimeout(done, 100)

    it "should reply", ->
      expect(room.messages).to.eql([
        ["user", "hubot hubot-sii"]
        ["hubot", "hubot-sii"]
      ])

fs = require 'fs'
assert = require 'assert'
should = require('chai').should()
expect = require('chai').expect
bond = require 'bondjs'
{LasershipClient} = require '../lib/lasership'
{ShipperClient} = require '../lib/shipper'

describe "lasership client", ->
  _lsClient = null

  before ->
    _lsClient = new LasershipClient()

  describe "requestOptions", ->
    _options = null

    before ->
      _options = _lsClient.requestOptions trackingNumber: 'LA40305346'

    it "creates a GET request", ->
      _options.method.should.equal 'GET'

    it "uses the correct URL", ->
      _options.uri.should.equal "http://www.lasership.com/track/LA40305346/json"

  describe "validateResponse", ->

  describe "integration tests", ->
    _package = null

    describe "delivered package", ->
      before (done) ->
        fs.readFile 'test/stub_data/lasership_delivered.json', 'utf8', (err, doc) ->
          _lsClient.presentResponse doc, 'trk', (err, resp) ->
            should.not.exist(err)
            _package = resp
            done()

      it "has a status of delivered", ->
        expect(_package.status).to.equal ShipperClient.STATUS_TYPES.DELIVERED

      it "has a destination of NYC", ->
        expect(_package.destination).to.equal "New York, NY 10001"

      it "has a weight of 2.282 lbs", ->
        expect(_package.weight).to.equal "2.282 LBS"

      it "has four activities with timestamp, location and details", ->
        expect(_package.activities).to.have.length 4
        act = _package.activities[0]
        expect(act.timestamp).to.deep.equal new Date '2014-03-04T16:45:34'
        expect(act.location).to.equal 'New York, NY 10001-2828'
        expect(act.details).to.equal 'Delivered'
        act = _package.activities[3]
        expect(act.timestamp).to.deep.equal new Date '2014-03-04T04:36:12'
        expect(act.location).to.equal 'US'
        expect(act.details).to.equal 'Ship Request Received'

    describe "released package", ->
      before (done) ->
        fs.readFile 'test/stub_data/lasership_released.json', 'utf8', (err, doc) ->
          _lsClient.presentResponse doc, 'trk', (err, resp) ->
            should.not.exist(err)
            _package = resp
            done()

      it "has a status of delivered", ->
        expect(_package.status).to.equal ShipperClient.STATUS_TYPES.DELIVERED

      it "has a destination of NYC", ->
        expect(_package.destination).to.equal "Pinellas Park, FL 33782"

      it "has a weight of 2.282 lbs", ->
        expect(_package.weight).to.equal "1.31 LBS"

var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');

var jg = require('../../app/scripts/judge');
var st = require('../../app/scripts/models/state');
var ord = require('../../app/scripts/models/order');
var dfs = require('../../app/scripts/models/defs');

(function () {
    'use strict';

    describe('Judge', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        var defs = new dfs.Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));
        for (var testnum in doc) {
            describe('for Testcase ' + doc[testnum].testCaseID, function () {
                var state = new st.State(doc[testnum].state);

                var orders = {};
                for (var nation in doc[testnum].orders) {
                    orders[nation] = [];
                    for (var orderStr in doc[testnum].orders[nation]) {
                        var order = ord.Order.fromString(orderStr);
                        order.test_expectedSucceeds = doc[testnum].orders[nation][orderStr];
                        orders[nation].push(order);
                    }
                }

                var judge = new jg.Judge(defs);

                orders = judge.judge(state, orders);

                for (nation in orders) {
                    for (var orderNum in orders[nation]) {
                        var o = orders[nation][orderNum];
                        it('should judge order ' + o.str + ' correctly', function () {
                            (o.succeeds()).should.equal(o.test_expectedSucceeds);
                        });
                    }
                }
            });
        }
    });
})();

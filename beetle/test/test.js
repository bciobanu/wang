const supertest = require('supertest')
const should = require('should')

process.env.NODE_ENV = 'test'

const server = require('../index')

describe('Register and Login unit test', function () {
    it('should register user', function (done) {
        supertest(server).post('/api/auth/register')
            .send({username: 'user1', password: 'password1'})
            .expect('Content-type', /json/)
            .expect(200)
            .end(function (err, res) {
                if (err)
                    done(err)
                    
                // HTTP status should be 200
                res.status.should.equal(200)
                // auth key should be true
                res.body.auth.should.equal(true)
                // token should exist
                res.body.should.have.ownProperty('token')
                should.notEqual(res.body.token, '')
                
                done()
            })
    })
})

server.close()

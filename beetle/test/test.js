const supertest = require('supertest')
const should = require('should')

process.env.NODE_ENV = 'test'

const index = require('../index')
server = index.server
DB = index.DB

describe('Register unit test', () => {
    it('should register user', done => {
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

let token = null
describe('Authenticate user unit test', () => {
    it('should authenticate user', done => {
        supertest(server).post('/api/auth/login')
        .send({username: 'user1', password: 'password1'})
        .expect('Content-type', /json/)
        .expect(200)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 200
            res.status.should.equal(200)
            // auth key should be true
            res.body.auth.should.equal(true)
            // token should be retreived
            res.body.should.have.ownProperty('token')
            should.notEqual(res.body.token, '')
            token = res.body.token

            done()
        })
    })
})

describe('Get figures unit test', () => {
    it('should return figures', done => {
        supertest(server).get('/api/figure')
        .set('x-access-token', token)
        .expect('Content-type', /json/)
        .expect(200)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 200
            res.status.should.equal(200)
            // body should contain an array
            Array.isArray(res.body)

            done()
        })
    })
})

describe('Auth check unit test', () => {
    it('should return 401', done => {
        supertest(server).get('/api/figure')
        .expect('Content-type', /json/)
        .expect(401)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 401
            res.status.should.equal(401)
            // auth key should be false
            res.body.auth.should.equal(false)
            // message key should be No token
            res.body.message.should.equal("No token")

            done()
        })
    })
})

let figId = null
describe('Create figure unit test', () => {
    it('should create figure and return its id', done => {
        supertest(server).post('/api/figure')
        .send({name: 'figure1', code: "code one one"})
        .set('x-access-token', token)
        .expect('Content-type', /json/)
        .expect(201)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 201
            res.status.should.equal(201)
            // body should contain the id
            res.body.should.be.aboveOrEqual(1)
            figId = res.body

            done()
        })
    })
})

describe('Update figure unit test', () => {
    it('should update figure', done => {
        supertest(server).put('/api/figure/' + figId)
        .send({name: 'figure2', code: "code one two"})
        .set('x-access-token', token)
        .expect('Content-type', /json/)
        .expect(201)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 201
            res.status.should.equal(201)

            done()
        })
    })
})

describe('Delete figure unit test', () => {
    it('should delete figure', done => {
        supertest(server).delete('/api/figure/' + figId)
        .set('x-access-token', token)
        .expect('Content-type', /json/)
        .expect(200)
        .end((err, res) => {
            if (err)
                done(err)
            // HTTP status should be 201
            res.status.should.equal(200)

            done()
        })
    })
})

server.close()

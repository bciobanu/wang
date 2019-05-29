const supertest = require('supertest')
const should = require('should')

process.env.NODE_ENV = 'test'

const server = require('../index')

const DB = require('../appConfig/dbconfig')

const UserDao = require('../dao/userDao')
const userDao = new UserDao()

const FigureDao = require('../dao/figureDao')
const figureDao = new FigureDao()

const User = require('../model/user')

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
        .expect('Content-type', /json/)
        .set('x-access-token', token)
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

server.close()

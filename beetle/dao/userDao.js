const User = require('../model/user')
const daoCommon = require('./commons/daoCommon')

class UserDao {
    constructor() {
        this.common = new daoCommon()
    }

    /**
     * Find the user with the specified id
     * @param id the id of the user we want to fine
     * @returns the found user 
     */
    findById(id) {
        let sqlRequest = "SELECT id, username, hashed_password FROM user WHERE id=$id"
        let sqlParams = {$id: id}

        return this.common.findOne(sqlRequest, sqlParams).then(row => 
            new User(row.id, row.username, row.hashed_password))
    }

    /**
     * Find the user with the specified username
     * @param username the username of the user we want to fine
     * @returns the found user 
     */
    findByUsername(username) {
        let sqlRequest = "SELECT id, username, hashed_password FROM user WHERE username=$username"
        let sqlParams = {$username: username}

        return this.common.findOne(sqlRequest, sqlParams).then(row => 
            new User(row.id, row.username, row.hashed_password))
    }

    /**
     * Get all users
     * @returns a list of all users
     */
    findAll() {
        let sqlRequest = "SELECT * FROM user"
        return this.common.findAll(sqlRequest, {}).then(rows => {
            let users = [];
            for (const row of rows) {
                users.push(new User(row.id, row.username, row.hashed_password))
            }
            return users
        })
    }

     /**
     * Update a user
     * @param User a user entity
     * @returns irrelevant
     */
    update(User) {
        let sqlRequest = "UPDATE user SET username=$username, hashed_password=$hashed_password " +
            "WHERE id=$id"
        let sqlParams = {$id: User.id, $username: User.username, $hashed_password: User.hashedPassword}
        return this.common.run(sqlRequest, sqlParams)
    }

    /**
     * Create a user
     * @param User a user entity (without the id field)
     * @returns the id of the newly created user
     */
    create(User) {
        let sqlRequest = "INSERT into user (username, hashed_password) " +
            "VALUES ($username, $hashed_password)"
        let sqlParams = {$username: User.username, $hashed_password: User.hashedPassword}
        return this.common.run(sqlRequest, sqlParams)
    }
}

module.exports = UserDao

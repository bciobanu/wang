const User = require('../model/user')
const daoCommon = require('./commons/daoCommon')

class UserDao {
    constructor() {
        this.common = new daoCommon()
    }

    findById(id) {
        let sqlRequest = "SELECT id, username, hashed_password FROM user WHERE id=$id"
        let sqlParams = {$id: id}

        return this.common.findOne(sqlRequest, sqlParams).then(row => 
            new User(row.id, row.username, row.hashed_password))
    }

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

    update(User) {
        let sqlRequest = "UPDATE user SET username=$username, hashed_password=$hashed_password " +
            "WHERE id=$id"
        let sqlParams = {$id: User.id, $username: User.username, $hashed_password: User.hashedPassword}
        return this.common.run(sqlRequest, sqlParams)
    }

    create(User) {
        let sqlRequest = "INSERT into user (username, hashed_password) " +
            "VALUES ($username, $hashed_password)"
        let sqlParams = {$username: User.username, $hashed_password: User.hashedPassword}
        return this.common.run(sqlRequest, sqlParams)
    }
}

module.exports = UserDao

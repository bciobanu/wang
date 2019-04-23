// User entity

class User {
    constructor(id, username, hashedPassword) {
        this.id = id
        this.username = username
        this.hashedPassword = hashedPassword
    }
}

module.exports = User

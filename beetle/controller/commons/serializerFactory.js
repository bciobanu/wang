const User = require('../../model/user')

class SerializerFactory {
    userSerializer() {
        return User => {
            return {id: User.id, username: User.username}
        }
    }
}

module.exports = SerializerFactory

// Load User entity
const User = require('../model/user')

// methods that return JSON serializers
class SerializerFactory {
    /**
     * @returns serializer for User entity (projection of User without password hash)
     */
    userSerializer() {
        return User => {
            return {id: User.id, username: User.username}
        }
    }
}

module.exports = SerializerFactory

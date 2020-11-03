module.exports = [
    // Replicate user attributes in ratings
    {
        rule: 'REPLICATE_ATTRIBUTES',
        source: {
            collection: 'users',
        },
        targets: [
            {
                collection: 'ratings',
                foreignKey: 'userId',
                attributeMapping: { 
                    'username': 'username', 
                    'photoURL': 'photoURL', 
                },
            }
        ],
    },
    // Remove ratings when restaurant is removed
    {
        rule: 'DELETE_REFERENCES',
        source: {
            collection: 'restaurants',
        },
        targets: [
            {
            collection: 'ratings',
            foreignKey: 'restaurantId',
            },
        ],
    },
];
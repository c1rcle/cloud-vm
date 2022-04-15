db = connect("mongodb://localhost/admin")

db.createUser({
    user: "admin",
    pwd: passwordPrompt(),
    roles: [
        { role: "userAdminAnyDatabase", db: "admin" },
        { role: "readWriteAnyDatabase", db: "admin" }
    ]
})

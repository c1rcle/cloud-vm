db.createUser({
  user: "admin",
  pwd: passwordPrompt(),
  roles: [{ role: "root", db: "admin" }],
});

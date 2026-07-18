# Admin setup

The application reads the signed-in user's `role` from the `users` table.
Promote an existing account to admin with:

```sql
UPDATE users
SET role = 'admin'
WHERE email = 'your-admin@email.com';
```

Log out and sign in again after changing the role. The **Admin Dashboard** item
will then appear in the menu.

This database update is required only for the first admin. After that, open the
**Users** tab in Admin Dashboard to promote or demote other accounts without
using phpMyAdmin again. The current admin cannot change their own role, and the
API prevents the system from losing its final admin account.

Regular accounts created by `register.php` receive the `user` role.

## Recommended favorite constraint

After removing any duplicate rows from `favorites`, add a unique constraint so
the same user cannot favorite the same book more than once:

```sql
ALTER TABLE favorites
ADD CONSTRAINT unique_user_book UNIQUE (user_id, book_id);
```

Category deletion is blocked while the category still contains books. Move or
delete those books first to avoid breaking their category relationship.

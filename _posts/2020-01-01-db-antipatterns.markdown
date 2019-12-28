---
layout: post
title: "Database: Anti-Patterns"
categories: programming
permalink: /db-anti-patterns
---

If you persist data, it's a crucial part of your system.
You can easily and quickly deploy a fix for a bug in your brand new dating site,
so farmer Joe from North Texas can finally read the latest message from his pen lover
and find out that she loves bald men.
But god help you if you lost or corrupted user's data.

![](/assets/db-anti-patterns/delete.png)
*[Silicon Valley, S02E08](https://www.imdb.com/title/tt3682604/?ref_=ttep_ep8)*

Yet many developers don't quite understand this simple truth.
I've been a professional programmer for not so many years, but I've seen a lot, plenty of mistakes people made working with DBs.

These are just off the top of my head.

## No Backups

![](/assets/db-anti-patterns/hippopotamus.jpg)

"Back up your data" is one of those rules like "don't run as root" or "fasten your belt" that many of us know and agree with
but don't follow, hoping that bad things happen to others, not ourselves.

By the way, if you don't test recovery from backups, you can assume that you have no backups at all.
[Learn from the mistakes of others](https://about.gitlab.com/blog/2017/02/01/gitlab-dot-com-database-incident/):

> So in other words, out of five backup/replication techniques deployed none are working reliably or set up in the first place. We ended up restoring a six-hour-old backup.

> We lost six hours of database data (issues, merge requests, users, comments, snippets, etc.) for GitLab.com.

## NoSQL

Sometimes
~~your users have too much adult content and watch it too frequently~~
the amount of data is too large or the load is too high that relational databases can't cope.
This is the case when NoSQL technologies come into play.
Software giants like Google are familiar with it firsthand.

But [you are not Google](https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb).
Several hundred gigabytes is not big data, and 1000 comments per day is not a high load.
Most probably, PostgreSQL is just fine for your data.
Look, it even [supports JSON and can index it](https://www.postgresql.org/docs/9.4/datatype-json.html).

Come on, do you really want to sacrifice a solid structure for features you don't need and - let's face it - will never need?
You won't become a new Google, you've just get a mess in your DB.

## Loose Schema

It's more relevant for NoSQL, but users of RDBMSes often forget or are lazy to create all necessary constraints.
Due to a bug in the application code, `NULL` can be stored when a value is required, or a reference to a missing row can be created.
Later on you discover it and fix the code, but you have no idea how to fix data.

## Natural Primary Keys

Imagine that we want to store users each of which must have a unique e-mail.
The most obvious solution is to create `user` table with `email` column which is a primary key as well.

Unfortunately, a natural key can become unusable as a primary key when business requirements change (and then constantly do).
Today `PRIMARY KEY(email)` is fine, but tomorrow we decide to add Facebook Login and make an e-mail optional.
What is better, to generate unique e-mails and introduce a flag indicating a fictive e-mail,
or to modify the primary key, all foreign keys referencing `user`, and so on, and so on?
We wouldn't have to choose the lesser of two evils if we just used a surrogate primary key.

## Logic In Stored Procedures

I dislike it for two reasons:
1. Application code is usually much easier to update than DB schema.
1. All those PL SQLs remind me Pascal and are just as ugly.

## Environment-Specific Update Scripts

I know that sometimes there is no choice, but in general,
it's better to try to keep all environments (dev, test, prod, etc.) as similar as possible.
The bigger the difference between environments,
the more likely it is to make a mistake and discover it only in production.

Usually even DML scripts can be universal.
Different schemas are most often pure evil.

So when I see environment-specific labels in Liquibase scripts, I reach for my gun.

## Tolerant Update Scripts

`IF NOT EXISTS` or something in DDL statements are not necessary
if you keep the same schema in all environments,
but can mask bugs.
If something unexpected happens during DB update,
I prefer to know and fix it ASAP.
Not to puzzle over a week later how to fix the mess.

## Non-Atomic Updates

Suppose you apply a changeset, which contains multiple statements, to the production DB,
and the migration fails.
You fix something and want to try again.
Will you succeed?
What if some statements from the changeset have been applied while the others have not?

You may notice that what I'm talking about here is that changesets should be *idempotent* and be right.

Unfortunately, many developers, when thinking about idempotency,
end up with `IF NOT EXISTS` or something.
In the previous section I explained why the latter is evil.

Instead, make your changesets *atomic*.
Then, in case of a failure, the applied changes are rolled back,
and you have to problem applying the changeset later.

But be careful relying on transactions.
For instance,
[support for DDL statements in MySQL transactions is dark and full of terrors](https://dev.mysql.com/doc/internals/en/transactions-notes-on-ddl-and-normal-transaction.html),
so I always create a dedicated changeset for each DDL statement
when writing Liquibase scripts for MySQL.

<br />
<br />

Which anti-patterns have you seen?
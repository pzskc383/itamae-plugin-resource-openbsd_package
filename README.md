# Itamae::Plugin::Resource::OpenBSDPackage

(M)Itamae plugin for installing/removing packages on openbsd

## Why?

Because builtin `package` resource can't handle openbsd's flavor and branch semantics.

```ruby
openbsd_package "vim" do
  flavor "no_x11"
end
```

Also, because current (as of early 2026) specinfra simply doesn't implement delete action for packages on OpenBSD.


## Status

- MItamae version is actually tested and used. Itamae one is written out of boredom.
- Zero tests at the moment

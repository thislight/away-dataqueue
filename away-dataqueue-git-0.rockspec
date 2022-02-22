package = "away-dataqueue"
version = "git-0"
source = {
   url = "git+https://github.com/thislight/away-dataqueue.git",
}
description = {
   homepage = "https://github.com/thislight/away-dataqueue",
   license = "GPL-3",
   summary = "general purpose asynchronous data queue for away",
}
dependencies = {
   "away >=0.1.3, <1"
}
build = {
   type = "builtin",
   modules = {
      ['away.dataqueue'] = "away/dataqueue.lua",
   }
}

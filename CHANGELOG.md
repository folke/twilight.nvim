# Changelog

## 1.0.0 (2023-01-04)


### Features

* added config option for default bg when transparent [#20](https://github.com/folke/twilight.nvim/issues/20) ([04d0f27](https://github.com/folke/twilight.nvim/commit/04d0f2792f84a1135bb0db86a4e4942eb9f67aad))
* added config option to dim inactive windows. Fixes [#5](https://github.com/folke/twilight.nvim/issues/5) ([35b0c01](https://github.com/folke/twilight.nvim/commit/35b0c01fb8a978531fa648d156ce99fd1f97c4c9))
* allow disabling treesitter ([8ab43c0](https://github.com/folke/twilight.nvim/commit/8ab43c0fdc246fdd82382d7ef4ec383f8f755ef9))
* initial version ([16f6a9a](https://github.com/folke/twilight.nvim/commit/16f6a9ada7c26c46e1e3096204498a03642d5af0))


### Bug Fixes

* add setup to init ([f5718dd](https://github.com/folke/twilight.nvim/commit/f5718ddbd9bba3184493a4fc11cd38342966904f))
* calc hl group on enable and on ColorScheme. no need to do during setup ([9c9adb9](https://github.com/folke/twilight.nvim/commit/9c9adb93c6fcacb7f87fd14b5f3c87006f99b3c0))
* properly dim all windows when Twilight is enabled ([30ef601](https://github.com/folke/twilight.nvim/commit/30ef601f36db80dc5daa46c89a66fe4d84176c47))
* remove dependency on nvim-treesitter ([9531b8e](https://github.com/folke/twilight.nvim/commit/9531b8ea93869f5feac63cb154c325ea603c5392))
* set extmark prio to 10000 to prevent other plugins to bleed through the dimming. Fixes [#4](https://github.com/folke/twilight.nvim/issues/4) ([0ac66e8](https://github.com/folke/twilight.nvim/commit/0ac66e85f2d8d7c6eb7d263ffc39fa19b56d882f))
* use pcall for treesitter check. Fixes [#7](https://github.com/folke/twilight.nvim/issues/7) ([f722fa2](https://github.com/folke/twilight.nvim/commit/f722fa24411d0423a3d2daf6f1b5f8b11df9db2b))

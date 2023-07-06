# Changelog

## 2023.2

* Manage rom 39SF040 for kernel and bank loading
* flag "-r -s 4" is no longer available, this version removes this case, but others set can be programmed
* Now flag -r -s X checks if X (set) is a right set
* flag "-k" is used to update kernel, it will check if the .r64 is a kernel .r64 file.
* Big cleaning of orixcfg source code.
* Big update for progress bar manangement, and orixcfg no longer clear screen when it update set.

## 2023.1

* generate man pages
* romupd in relocation format

## 2022.4

* Now orixcfg -i works again

## 2021.2

* Add new format of rom when we flush ram
* Add option to flush all ram (-w -f flags)
* can now load a rom in a ram bank with a flag (-l rom -b X).

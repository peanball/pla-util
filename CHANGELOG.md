# 2.0.0 (2022-06-11)

* Overhaul the command line syntax (any scripts that call `pla-util` will need to be updated).
  * Providing a network interface on the command line is no longer required (Issue [#8](https://github.com/serock/pla-util/issues/8)).
* Write error messages to the standard error stream.
* Set the exit status to 1 when an error occurs.
* Use libpcap for sending and receiving packets.

# 1.2.0 (2022-02-22)

* Fix the security level displayed by `get-network-info` command.
* Change the implementation of the `get-network-stats` command because the first implementation did not work with TL-PA7017 adapters.
* Add an optional power line adapter MAC address parameter to commands.
* Increase timeouts from 250 ms to 500 ms.
* Add `get-discover-list` command.
* Check for too many command line arguments.

# 1.1.0 (2022-02-11)

* Add `get-network-stats` command (Issue [#7](https://github.com/serock/pla-util/issues/7)).
* Add `get-id-info` and `get-capabilities` commands.
* Change the output of the `discover` command to include the power line adapter interface.
* Change the output of the `get-network-info` command to reverse the byte-order of the NID and display the security level.
* Show the version of `pla-util` when no arguments are provided on command line.
* Improve exception handling.
* Clean up README (Issue [#6](https://github.com/serock/pla-util/issues/6)).

# 1.0.0 (2021-07-06)

* Initial release.

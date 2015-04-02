# poor mans require
function require($bin) {
  if (!(get-command $bin -ea silentlycontinue)) {
    "$bin is required to run but was not found."
    exit 1;
  }
}
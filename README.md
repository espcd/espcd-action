# espcd github action

This action compiles an arduino sketch for the given fqbn and uploads it to the espcd backend.

## Inputs

### `url`

**Required** The url of the backend firmwares path. Default `"https://api.espcd.duckdns.org/firmwares"`.

### `fqbn`

**Required** The fully qualified board name of the device, e.g.: esp8266:esp8266:generic.

### `sketch`

**Required** Path to the arduino sketch that should be compiled.

### `product`

The id of the product that should be assiciated with the firmware.

### `title`

The title of the firmware. Default `""`.

### `description`

The description of the firmware. Default `""`.

## Example usage

```
steps:
  - uses: actions/checkout@v2
  - name: Setup arduino cli
    uses: arduino/setup-arduino-cli@v1
  - uses: espcd/espcd-action@master
    with:
      fqbn: 'esp8266:esp8266:generic'
      sketch: ./my-sketch.ino
```

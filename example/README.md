# picoruby-bootsel Example

BOOTSEL ボタンを押している間、オンボード LED が点灯するサンプルプログラム。

## 前提条件

- arm-none-eabi-gcc
- cmake (3.22 以上)
- Ruby (3.0 以上) + Bundler
- Pico SDK 2.2.0

## ビルド手順

### 1. R2P2 のセットアップ

```sh
git clone https://github.com/picoruby/R2P2.git
cd R2P2
rake setup
```

### 2. ビルド設定のコピー

このリポジトリの `build_config/r2p2-bootsel-pico.rb` を R2P2 の `build_config/` にコピーする。

```sh
cp /path/to/picoruby-bootsel/example/build_config/r2p2-bootsel-pico.rb build_config/
```

### 3. Rakefile にビルドターゲットを追加

R2P2 の `Rakefile` で `%w[picoruby microruby]` のループ内にある `%w[pico pico_w pico2 pico2_w]` のボード一覧は既存のものをそのまま使う。ビルド設定名が `r2p2-bootsel-pico` なので、以下のように直接ビルドを実行する。

```sh
cd lib/picoruby
MRUBY_CONFIG=../../build_config/r2p2-bootsel-pico.rb rake
cd ../..
```

### 4. CMake でファームウェアをビルド

```sh
BUILD_DIR=build/bootsel/pico/prod

mkdir -p $BUILD_DIR
cmake -B $BUILD_DIR \
  -D EXTRA_LIBRARY_PATH=$(pwd)/lib/picoruby/build/r2p2-bootsel-pico/lib \
  -D EXTRA_INCLUDE_DIR=$(pwd)/lib/picoruby/build/r2p2-bootsel-pico/include \
  -D PICO_CYW43_SUPPORTED=1 \
  -D MRUBY_CONFIG=$(pwd)/build_config/r2p2-bootsel-pico.rb \
  -D BUILD_DIR=$BUILD_DIR \
  -D PICORB_VM_MRUBYC=1 \
  -D R2P2_NAME=R2P2-BOOTSEL-PICO \
  -D PICO_PLATFORM=rp2040 \
  -D PICO_BOARD=pico \
  -D CMAKE_BUILD_TYPE=Release \
  -D NDEBUG=1 \
  -D PICORUBY_MSC_FLASH=1

cmake --build $BUILD_DIR
```

ビルドが成功すると `$BUILD_DIR/` に `.uf2` ファイルが生成される。

### 5. Pico への書き込み

1. Pico の BOOTSEL ボタンを押しながら USB ケーブルを接続する
2. マスストレージデバイスとしてマウントされる
3. `.uf2` ファイルをドラッグ＆ドロップ（または `cp`）する

```sh
cp $BUILD_DIR/*.uf2 /media/$USER/RPI-RP2/
```

### 6. サンプルプログラムの実行

Pico が R2P2 として起動したら、シリアルコンソール（USB CDC）で接続する。

```sh
screen /dev/ttyACM0 115200
```

R2P2 のシェルが表示されたら、`app.rb` の内容をファイルに書き込んで実行する。

```ruby
# R2P2 シェル上で直接入力するか、ファイルシステムに保存して実行
led = GPIO.new(25, GPIO::OUT)
while true
  if Bootsel.pressed?
    led.write 1
  else
    led.write 0
  end
  sleep 0.05
end
```

BOOTSEL ボタンを押すと LED が点灯し、離すと消灯する。

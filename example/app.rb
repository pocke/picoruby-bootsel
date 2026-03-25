require "bootsel"

led = GPIO.new(25, GPIO::OUT)

while true
  if Bootsel.pressed?
    led.write 1
  else
    led.write 0
  end
  sleep 0.05
end

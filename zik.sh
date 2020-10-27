#!/bin/bash

 echo "Executing $0"
listtube(){
  # Using "Here Document"
  cat << 'EOH'
    42 melody      : t*(42&t>>10)
    Sierpinski     : t & t/256
    StarLost       : ((t % 255) ^ (t % 511)) * 3
    Mistery Trans  : (t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
    Hard Carry     : t*(t^t+(t>>15|1)^(t-1280^t)>>10)
    DickJockey     : (t*(t>>5|t>>8))>>(t>>16)
    Nimpho Piano   : t*(((t>>9)&10)|((t>>11)&24)^((t>>10)&15&(t>>15)))
EOH
}
byteplay(){
  # Determine the sound reader present
  cmd="aplay"
  # If aplay exists (Linux) => just pass
  if command -v aplay > /dev/null; then
    :
  # Else, If sox command exists (Android) => use the big, hacky pipe
  elif command -v sox > /dev/null; then
    cmd="sox -t raw -b 8 -e signed -c 1 -r 8000 - -t wav - | play -"
  # Otherwise (Problem) => Notify user to install sox (in StdErr)
  else
    >&2 echo "ERROR: Cannot reproduce music on your device !"
    >&2 echo "Please install sox => apt install sox"
    exit 1
  fi

  # Play the equation given as parameter
  for((t=0;;t++));do((n=(
  $1
  ), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c"; done | eval $cmd
}


bytegui(){
  # Ask user for the equation to play (in list)
  # Require: dialog

  # Define list (with associative array) <= tubelist
  declare -A bytelist=()
  while read -r line; do
    # Get key <= before the first ":"
    key="${line%%:*}"
    # Remove trailing whitespace characters
    key="${key%"${key##*[![:space:]]}"}"

    # Get value <= after the first ":"
    value="${line#*: }"

    # Set array
    bytelist[$key]="$value"
  done <<< "$(listtube)"


  # Create array with both key and value, to give to dialog
  declare -a bytekeyval
  for key in "${!bytelist[@]}"; do
    bytekeyval+=("$key" "${bytelist[$key]}")
  done

  # Get user input
  name=$(dialog \
    --backtitle "ByteBeater" \
    --clear \
    --menu "Choose equation to bytebeat!" 0 0 "${#bytelist}" \
    "${bytekeyval[@]}" \
    --output-fd 1 \
  )

  # Play melody
  equation="${bytelist[$name]}"
  echo "Playing: $name => $equation"
  byteplay "$equation"
}

bytegui
declare -A bytelist=(
    ['42 melody']='t*(42&t>>10)'
    ['Sierpinski']='t & t/256'
    ['StarLost']='((t % 255) ^ (t % 511)) * 3'
    ['Mistery Trans']='(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)'
  )



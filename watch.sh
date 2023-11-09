#!/bin/bash
NOTEBOOK_FILE="polars.ipynb"
SLIDES_DIR="slides_output"
SLIDES_FILE="$SLIDES_DIR/$(basename "$NOTEBOOK_FILE" .ipynb).slides.html"
HTTP_SERVER_PID=0

# Function to convert notebook to slides
convert_to_slides() {
  jupyter nbconvert "$NOTEBOOK_FILE" \
      --to slides \
      --output-dir="$SLIDES_DIR" \
      --SlidesExporter.reveal_theme=serif
      # --SlidesExporter.reveal_scroll=True
  cp "$SLIDES_DIR/polars.slides.html" "$SLIDES_DIR/index.html"
  # Additional commands can be added here if you need to copy the slides to a different directory
}

# Initial conversion
convert_to_slides

# Function to start http.server and save its PID
start_http_server() {
  python -m http.server --directory "$SLIDES_DIR" 8000 &
  HTTP_SERVER_PID=$!
}

# Function to stop http.server
stop_http_server() {
  if [ $HTTP_SERVER_PID -ne 0 ]; then
    kill $HTTP_SERVER_PID
  fi
}

# Function to handle script exit
cleanup() {
  stop_http_server
  exit 0
}

trap cleanup INT

start_http_server

# Use fswatch to monitor the notebook for changes and rerun the nbconvert command
fswatch -o "$NOTEBOOK_FILE" | while read f; do
  convert_to_slides
  echo "Converted slides after change detected at $(date)"
done


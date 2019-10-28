FRAMEWORK="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Crittercism.framework"
LIBRARY="${FRAMEWORK}/Crittercism"

echo "Stripping framework $FRAMEWORK"
echo "Current architecture: $arch"

existingArchitectures="$(lipo -info "$LIBRARY" | rev | cut -d ':' -f1 | rev)"
strippedArchitectures=""

echo "Bundled architectures: $existingArchitectures"

for arch in $existingArchitectures; do
  if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      lipo -remove "$arch" -output "$LIBRARY" "$LIBRARY" || exit 1
      strippedArchitectures="$strippedArchitectures $arch"
    fi
done

echo "Stripped: $strippedArchitectures"
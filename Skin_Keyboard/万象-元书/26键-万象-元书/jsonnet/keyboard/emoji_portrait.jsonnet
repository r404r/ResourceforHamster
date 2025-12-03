local collectionData = import '../lib/collectionData.libsonnet';
local symbolic = import './symbolic_portrait.jsonnet';

local keyboard(theme) =
  symbolic.getKeyboard(theme);


{
  new(theme, orientation='portrait'):
    keyboard(theme) + collectionData.emojiDataSource,
}

import { registerUnbound } from "discourse-common/lib/helpers";
import { emojiUnescape } from "discourse/lib/text";
import { htmlSafe } from "@ember/template";

registerUnbound("replace-emoji", (text, options) => {
  return htmlSafe(emojiUnescape(text, options));
});

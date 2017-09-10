exports.delete_symbols = function(text) {
  return text.replace(/[【】、。《》「」〔〕・（）［］｛｝！＂＃＄％＆＇＊＋，－．／：；＜＝＞？＠＼＾＿｀｜￠￡￣\(\)\[\]<>{},!? \.\-\+\\~^='&%$#\"\'_\/;:*‼•一]/g, "");
}

exports.delete_reply_and_hashtag = function(text) {
  return text.replace(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/g, "");
}

exports.delete_retweet = function(text) {
  return text.replace(/RT[;: ]/g, "");
}

exports.delete_url = function(text) {
  return text.replace(/(https?|ftp|wss?)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)/g, "");
}
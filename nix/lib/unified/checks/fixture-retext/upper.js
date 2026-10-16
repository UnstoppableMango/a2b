// A local plugin, named by path: upper-cases every word.
export default function upper() {
  return function (tree) {
    visit(tree)
  }
}

function visit(node) {
  if (node.type === 'TextNode' && node.value) node.value = node.value.toUpperCase()
  for (const child of node.children || []) visit(child)
}

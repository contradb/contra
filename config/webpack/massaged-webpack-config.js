const environment = require("./environment")

const webPackConfig = environment.toWebpackConfig()

const tsRegexString = /\.(ts|tsx)?(\.erb)?$/.toString()

const tsClause = environment.config.module.rules.find(
  ({ test }) => test && test.toString() === tsRegexString
)

if (!tsClause) {
  throw new Error("could not find typescript clause in rules")
} else if (tsClause.use.length !== 1) {
  throw new Error(
    "surprised about the length of the use array not being 1: ",
    tsClause.use
  )
} else if (tsClause.use[0].loader !== "ts-loader") {
  throw new Error(
    "surprised about not finding ts-loader in the use array: ",
    tsClause.use
  )
} else {
  tsClause.use.push({ loader: "eslint-loader", options: {} })
}

module.exports = webPackConfig

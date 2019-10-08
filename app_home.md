## About footballpredict AI

footballpredict AI is a machine learning model for predicting winning odds in football matches. It makes its predictions using a deep ensemble of boosted trees, discriminant analysis and regression-based models. It uses past history of games and [ELO ratings](http://clubelo.com/) as training examples.

## Will it make me money?

This is highly unlikely. For a betting strategy based on a probabilistic model to be profitable in the long run, three conditions need to hold:

1. The model has to be well-calibrated, i.e. from 100 games for which it predicts home team winnning with 60% probability, 60 should end with home win;
2. The model has to to yield high probabilities of outcomes;
3. Bookmaker's odds have to underestimate the high-probability cases.

To see why all three are needed, consider an example. Imagine you have a perfectly calibrated model, but it doesn't predict higher then 70% chance of winning for one of the teams. If you only consider these 70% cases and bet $1 for 10 games, you will get it right 7 times and win (7 * $1 * average odds) and get it wrong three times loosing $3. For you to break even, the average odds would have to amount to 10/7 = 1.43, and even more would be needed to make you a profit. This is not very likely for games where the front-runner is pretty obvious. If the model was able to provide 90% winning chances at times, similar analysis shows that average odds of 1.11 are needed, which is more plausible for easy-to-predict games. Yet, for you to be profitable, bookmaker's odds would have to be even higher, so they would have to underestimate the front-runner's winning chance.

However, the first two points are contradictory to some extent - the better the model is calibrated, the less extreme predictions it provides. Moreover, the third condition will not be fulfilled in most cases.

## Contribute

All contributions are welcome! Check out the [source code](https://github.com/MichalOleszak/footballpredict) and contact [the author](https://michaloleszak.github.io/).

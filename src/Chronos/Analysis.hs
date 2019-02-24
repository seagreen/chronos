module Chronos.Analysis
  ( Benchmark(..)
  , Analysis(..)
  , sigma
  , stdError
  , step
  ) where

import Numeric.Natural

data Benchmark
  = Benchmark
  { name :: String
  , analysis :: Analysis
  , runner :: Analysis -> IO Analysis
  }

data Analysis
  = Analysis
  { samples :: Natural
  , squaredWeights :: Natural
  , mean :: Rational
  , qFactor :: Rational
  } deriving (Eq, Ord, Show, Read)

{-# INLINE step #-}
step :: Benchmark -> IO Benchmark
step (Benchmark n a f) = flip (Benchmark n) f <$> f a

sigma :: Analysis -> Double
sigma a = sqrt (fromRational $ variance a) / biasCorrection
  where biasCorrection
          = 1
          - 1/(4*fromIntegral (samples a))
          - 7/(32*fromIntegral (samples a)**2)
          - 19/(128*fromIntegral (samples a)**3)

stdError :: Analysis -> Double
stdError a | samples a == 1 = fromRational (mean a)
           | otherwise = sigma a * sqrt (fromIntegral $ squaredWeights a) / fromIntegral (samples a)

variance :: Analysis -> Rational
variance a | samples a > 1 = qFactor a / fromIntegral (samples a - 1)
           | otherwise = 0

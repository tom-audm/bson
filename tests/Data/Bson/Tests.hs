{-# LANGUAGE FlexibleInstances, OverloadedStrings, TypeSynonymInstances #-}

module Data.Bson.Tests
    ( tests
    ) where

#if !MIN_VERSION_base(4,8,0)
import Control.Applicative ((<$>), (<*>))
#endif
#if MIN_VERSION_base(4,9,0)
import Control.Monad.Fail(MonadFail(..))
#endif
import Data.Int (Int32, Int64)
import Data.Time.Calendar (Day(ModifiedJulianDay))
import Data.Time.Clock.POSIX (POSIXTime)
import Data.Time.Clock (UTCTime(..), addUTCTime)
import qualified Data.ByteString as S

import Data.Text (Text)
import Test.Framework (Test, testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck (Arbitrary(..), elements, oneof, Property, (===))
import qualified Data.Text as T

import Data.Bson (Val(cast', val), ObjectId(..), MinMaxKey(..), MongoStamp(..),
                  Symbol(..), Javascript(..), Regex(..), UserDefined(..),
                  MD5(..), UUID(..), Function(..), Binary(..), Field((:=)),
                  -- Document,
                  Value(..))
import qualified Data.Bson as Bson

instance Arbitrary S.ByteString where
    arbitrary = S.pack <$> arbitrary

instance Arbitrary Text where
    arbitrary = T.pack <$> arbitrary

instance Arbitrary POSIXTime where
    arbitrary = fromInteger <$> arbitrary

instance Arbitrary UTCTime where
    arbitrary = do
        a <- arbitrary
        b <- arbitrary
        return $ addUTCTime (fromRational b)
               $ UTCTime (ModifiedJulianDay a) 0

instance Arbitrary ObjectId where
    arbitrary = Oid <$> arbitrary <*> arbitrary

instance Arbitrary MinMaxKey where
    arbitrary = elements [MinKey, MaxKey]

instance Arbitrary MongoStamp where
    arbitrary = MongoStamp <$> arbitrary

instance Arbitrary Symbol where
    arbitrary = Symbol <$> arbitrary

instance Arbitrary Javascript where
    arbitrary = Javascript <$> arbitrary <*> arbitrary

instance Arbitrary Regex where
    arbitrary = Regex <$> arbitrary <*> arbitrary

instance Arbitrary UserDefined where
    arbitrary = UserDefined <$> arbitrary

instance Arbitrary MD5 where
    arbitrary = MD5 <$> arbitrary

instance Arbitrary UUID where
    arbitrary = UUID <$> arbitrary

instance Arbitrary Function where
    arbitrary = Function <$> arbitrary

instance Arbitrary Binary where
    arbitrary = Binary <$> arbitrary

instance Arbitrary Field where
    arbitrary = (:=) <$> arbitrary <*> arbitrary

instance Arbitrary Value where
    arbitrary = oneof
        [ Bson.Float   <$> arbitrary
        , Bson.String  <$> arbitrary
        , Bson.Doc     <$> arbitrary
        , Bson.Array   <$> arbitrary
        , Bson.Bin     <$> arbitrary
        , Bson.Fun     <$> arbitrary
        , Bson.Uuid    <$> arbitrary
        , Bson.Md5     <$> arbitrary
        , Bson.UserDef <$> arbitrary
        , Bson.ObjId   <$> arbitrary
        , Bson.UTC     <$> arbitrary
        , Bson.RegEx   <$> arbitrary
        , Bson.JavaScr <$> arbitrary
        , Bson.Sym     <$> arbitrary
        , Bson.Int32   <$> arbitrary
        , Bson.Int64   <$> arbitrary
        , Bson.Stamp   <$> arbitrary
        , Bson.MinMax  <$> arbitrary
        , return Bson.Null
        ]

testVal :: Val a => a -> Bool
testVal a = case cast' . val $ a of
    Nothing -> False
    Just a' -> a == a'

#if MIN_VERSION_base(4,9,0)
instance MonadFail (Either String) where
   fail = Left

testLookMonadFail :: Property
testLookMonadFail =
   (Bson.look "key" [] :: Either String Value)
      -- This is as opposed to an exception thrown from Prelude.fail:
      === Left "expected \"key\" in []"
#endif

tests :: Test
tests = testGroup "Data.Bson.Tests"
    [ testProperty "Val Bool"        (testVal :: Bool -> Bool)
    , testProperty "Val Double"      (testVal :: Double -> Bool)
    , testProperty "Val Float"       (testVal :: Float -> Bool)
    , testProperty "Val Int"         (testVal :: Int -> Bool)
    , testProperty "Val Int32"       (testVal :: Int32 -> Bool)
    , testProperty "Val Int64"       (testVal :: Int64 -> Bool)
    , testProperty "Val Integer"     (testVal :: Integer -> Bool)
    , testProperty "Val String"      (testVal :: String -> Bool)
    , testProperty "Val POSIXTime"   (testVal :: POSIXTime -> Bool)
    , testProperty "Val UTCTime"     (testVal :: UTCTime -> Bool)
    , testProperty "Val ObjectId"    (testVal :: ObjectId -> Bool)
    , testProperty "Val MinMaxKey"   (testVal :: MinMaxKey -> Bool)
    , testProperty "Val MongoStamp"  (testVal :: MongoStamp -> Bool)
    , testProperty "Val Symbol"      (testVal :: Symbol -> Bool)
    -- , testProperty "Val Javascript"  (testVal :: Javascript -> Bool)
    , testProperty "Val Regex"       (testVal :: Regex -> Bool)
    , testProperty "Val UserDefined" (testVal :: UserDefined -> Bool)
    , testProperty "Val MD5"         (testVal :: MD5 -> Bool)
    , testProperty "Val UUID"        (testVal :: UUID -> Bool)
    , testProperty "Val Function"    (testVal :: Function -> Bool)
    , testProperty "Val Binary"      (testVal :: Binary -> Bool)
    -- , testProperty "Val Document"    (testVal :: Document -> Bool)
    , testProperty "Val Text"        (testVal :: Text -> Bool)

#if MIN_VERSION_base(4,9,0)
    , testProperty "'look' uses MonadFail.fail" testLookMonadFail
#endif
    ]

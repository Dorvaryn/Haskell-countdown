data Op = Add | Sub | Mul | Div
data Expr = Val Int | App Op Expr Expr

instance Show Op where
    show Add = "+"
    show Sub = "-"
    show Mul = "x"
    show Div = "/"

instance Show Expr where
    show (Val w) = show w
    show (App o l r) = show l ++ " " ++ show o ++ " " ++ show r

    showList [] = showString "[]"
    showList (e:es) = showChar '[' . shows e . showl es 
        where showl [] = showChar ']'
              showl (e:es) = showString ",\n " . shows e . showl es

valid :: Op -> Int -> Int -> Bool
valid Add _ _ = True
valid Sub x y = x > y
valid Mul _ _ = True
valid Div x y = x `mod` y == 0

apply :: Op -> Int -> Int -> Int
apply Add x y = x + y
apply Sub x y = x - y
apply Mul x y = x * y
apply Div x y = x `div` y

values :: Expr -> [Int]
values (Val n) = [n]
values (App _ l r) = values l ++ values r

eval :: Expr -> [Int]
eval (Val n) = [n | n > 0]
eval (App o l r) = [apply o x y | x <- eval l, y <- eval r, valid o x y]

subs :: [a] -> [[a]]
subs [] = [[]]
subs (x:xs) = yss ++ map (x:) yss where yss = subs xs

interleave :: a -> [a] -> [[a]]
interleave x [] = [[x]]
interleave x (y:ys) = [(x:y:ys)] ++ map (y:) (interleave x ys)

perms :: [a] -> [[a]]
perms [] = [[]]
perms (x:xs) = concat $ map (interleave x) (perms xs)

choices :: [a] -> [[a]]
choices = concat . map perms . subs

split :: [a] -> [([a],[a])]
split [] = []
split [_] = []
split (x:xs) = ([x],xs):[(x:ls, rs)|(ls,rs)<-split(xs)]

solution :: Expr -> [Int] -> Int -> Bool
solution e ns n = elem (values e) (choices ns) && eval e == [n]

exprs :: [Int] -> [Expr]
exprs [] = []
exprs [n] = [Val n]
exprs ns = [e| (ls,rs) <- split ns, l <- exprs ls, r <- exprs rs, e <- combine l r ]

ops :: [Op]
ops = [Add,Sub,Mul,Div]

combine :: Expr -> Expr -> [Expr]
combine l r = [App o l r | o <- ops]

solutions :: [Int] -> Int -> [Expr]
solutions ns n = [e | n' <- choices ns, e <- exprs n', eval e == [n]]

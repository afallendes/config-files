# functions

mdcd ()
{
    mkdir -vp -- "$1" && cd -P "$1"
}

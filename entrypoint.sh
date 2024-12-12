#! /bin/sh

echo Installing acme.sh
cat /acme-install.sh | sh -s email=$EMAIL

echo Email is $EMAIL
echo Dreamhost API key: $DH_API_KEY

echo
echo HOME is $HOME. Contents of $HOME
ls -alF $HOME

echo Contents of $HOME/.acme.sh/
ls -alF $HOME/.acme.sh/

# Pass --test to use it with the staging servers.

$HOME/.acme.sh/acme.sh \
    --issue \
    --dns $DNSAPI \
    -d $HOST \
    --debug

RESULT=$?

echo acme.sh finished with code: $RESULT

if [ $RESULT -eq 0 ]; then
    echo
    echo After certificate generation, contents of $HOME/.acme.sh/$HOST*
    ls -alF $HOME/.acme.sh/$HOST*
else
    echo
    echo Certificate has not been generated, not doing anything.
fi

#!/bin/bash
VALUE=$(cat)
echo -e "$VALUE"|sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'

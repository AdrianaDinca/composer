ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r��v����)')U*7���Kc�����Ԁ�h���I�l_Mh�A4����|­��7�y�w���.�"Y=3�y������ٺq�P�r>�;�D���ۺ�ﷵ'�h4L��bAa�?�PX�>Cb4BJ#��A���c <P��6-h ��2`W5��-{�+�.2L�;�E�Ǚ��22w8 �'��~�-���8�a�xO�C����� CCJ���1�b�lX�C x�-l;��V���j`��tk��<��ӥ��a!���� \{�(�24���&˽�mdAZ����`X�$��|,���@f���G��Vu~A�X����H6�E++�r:����ؘ�0��t�!&�Pב���E�0��`6m����d�Lڑ�몆O��N[S�Ú�ʋ�� S6Ԏ�,�7�0�a�AW��(X���ZW\��B�c��-l0�@�������d���*�̅��m�m��!AX���單���hنF��0:�N �R��K��h��`'&D���Na0�)�Bv؊�>��aтZm��K�:�FC̗��ʋŖ��oZV��_�~L�N�?�LD��9�����#�`=��裍L�Z:[fJ]�9�E���D]�̷��d޹�B��ۚvo0�8�td���bvEAuhk��@�2t�mɤ�:wq��m�?8ا���§�o�:y�Xd��G���b� ���"qA��{2�p�o��[��Q��;��o6��[�����A���P8ä\���ѵ��
x�]���4���mCF��	d��ST�jL��:!���ˇ�R2�N�0����tz
�8�0$�a�/X��a��S٧��Y�_�����/f��-�@���;��=��BdJ��k��"��No�{��r�D���?�N� ��Pfe&�0�3k�9G6���W�"w�q;Mtl����v;�څ�e؈�<W-l��� �Z�w� �$Z�i��&60���X3��>�nJyh[MlL�9%�N�4UF��ږ��4�/�E��$�#UF�~~��a/k�[rz�v��5�N�I;������nXV�9��Cg���<�lUS|А�j���[� �����r��pq����,D�f;��@)�)����	��׸R�G�?��9��»O�SO�uH?;�p����|�`�'iZ�����������?(�Bx��W���P/�m���	-�R5@]j�."����zc�R��J��;�[�5����7�B�c��-N��wԛ<���.�y��5%�U��&�>i�҆�ٛ�� |���sA��OF������d�p�����Kt���oӬ�� ��i�:�o�����d&�&�!B1���Ѩ�.����N�EVi��:��{L������:��c\��e�)����R��Oqֵ>����uу3�'1ǟ��ҧ�+R��wɅ���Z�����Ǿ�$��pG��.�!h"`"��5U�	0�l���眏��&cN�=`��xw�ȹs����-�%�ׁ��es	���l�^�N8oTi���w�=���� �[�_��Z���y}���C���#ʜ�u���_*̰�����������:�c%�>���a������X"�b8��q}��p������Μ�vFC<=m�գ5���nր5�I��R Z�x?��s�\i��	W�˕���R�3�Mȭ&�?��]���x~=�<xA�Ĝe��r3R��K��K��a���`�6�N�PM`�&�^'ݴ۴'l��_��50Ya׍*�f��4	E�x�|��,ݩ��o�"�*�\>}X����ڬ���i"�X��uc�wň3�h�ş�	�����YT��w��;�|fû�>| ޖ�9�s��
��@��5d����[
DZ��ɒ�NO��;���������� ?����"��1b3��Lv��܈��X�;�A!���Vk��ˆ��?hX�\&�!Q���b��Z�W/�ܳO����6Pu� �|�����%�qB��k��Z��0C�������L����������?W �ן�p��w^�Fp��+�ۮ�}����������Bѵ�_	L��M�]8���0-��@�Pu�}!�nC]1�݁�P�Z{d�w],�~��I�����63���ϋO���|LDȖ�����1�7�]�,���jdDz�r��"#��s��}U:�|��z9�y�L:s+d�E�߱w���F��,�=3��g�����y��+�6�0:�Sȣ3��b�E2V�x�L�_O�s���y�L�N��5�>�:�YCP_�\�����OP�2�O���B��[��Ǉ��P&��\��?��6]
Y�茨����k~nDk�ǁ�O�=�0���_\�/�;a�H�ޥ�{}�Nm`[n*��*��������e�	G��?	��%���V��Xƶ�hZ��uB�C?�'�����Q���J�����Z����p,���]	�W���?w�����B��ɸ��h H3���瀌��e ��-�]��̣�ɝ
�"��V�a���� ��ܡ�i}�P&������6z�.zqSwiƳ��LQr�\���l?�Ħ�$q�A�IC���):&��W`2���Ln�6�R�̜1��t��Y�1&*���T"���{���`a���S��J�3Ç��a7Jf�ե!��&4�)D�ˑ�wV2��{5���
���í��P�}Bw?�c�u����������.��Ax��_!�>��D���ϕ �_s�܇o����������5�S�營P�&��p0�]�EY�a�V���x�^���Da���x-
�0���b-�	ֶ#���������4�i�_���:M%�qD6��o����m�ɷ�9.�u�j�7�y㟸����__m��I"���7_���<�{����������w���?�!;��ߜd�j��xJ���+�)!m0��q~p�߮�{����3�Nm�]�����_|��{�&o�������Z��U����O J��Bʼ��0)�I���u�P����'Oo�6�,�w�ySm�s���X}�"�ak�EkuA�m����v��pm[���!Dx"��@A���1��1�0��H�G횗Q�uj�p|�l� ��R%��%�J�����\2{�LJr�!�r	��+I�P?.��+�D����T�ni�^�q���g��!Mp{�U��P�ZYI���|��8���J�Fᘐ�$[�f-��k�76<I_f.���L����35�}���}ԮN�ۗي�����t6�?�J�go���ۄyV�\Ԃ��^J�N�������L��^S.�+r�p��+9ᰒ�вV&���'�Z�h�����q��M��W�ҕ<�8:�d"�_fLxr֕ۑ�i%}�O��_���j0c��g�ӓ�|[��]�����0�^�xR��ID"s���e3����څn��8#3��g���r>��l2�~��$!'%����e�(f[��J�tc������EĊ��<��*o{�A��8����S�/�g�RV�H>v;��Rۅr,g散R�,��g���J%q���d-Ho�T/��t��))O�z��OH���t!I��IG��z�V>�/�m�ڱD.���Vo����&�������D�j�Md�p����72��IIhH�t5�+&��~1�^O�k�SކW��I<���^�R�*�'��q��T�\�ُ�v�M_����t������{��q~�
j?�ǺJ�Z�v���Ӆ�1���?��t��Ɓ��Iǌ�f������Q�
�'����3C�o`l-�[��W
�h�﫻}4����V��K�����?!Q����Vc~�Q)wL��O��ҧ\>��#6YZd�Y��U,6!�;8H�c5W[��S��P:��[TȞhZWˤ�|U�/�A�I\��$��n�,V�N�ں��d���q�����j<��ǭj�X��#E��{���H6O�*�v�0��P����?H�U�F�|�O9������_�2��������*��������'���e���?W����8�%����K�N��㏤T�BRRQNR�zF:���J�M��aL�it�Q;��Ç��L��F�]:{kgJ�&�>����+K�ںt�L�w)��:z���)���;n��{��g��� ����i`I]m�����D��7�#�u����3�ĝ���"s�<�ft�@�4P�e&(!���{F�,�Ro}N�[�s�[W��F�o	A�=j���th4L�@
�U]eS�N����^�i��4���t��/٥��П�yX┞��#�����Q �p����b��6�ȗ;Hf�XF��tAi��B���ѐ��X��G��������i9�����3�p���b��(,<��c�oC|T�e�G�;����h��:��q�V�e:�2�"�4�� ����E�j��hd"g}l.=�P��+? y����G/0���r)�"PAd���^9��Pp�a��P�0`�6HI�,CE&��&6`T֧m�*�A�zS�)��=��8 6K裭����4���/lP�0�n��^����$ɜa���C�2����B�S�r�G�z3���c�
���#8	�n�@Ɨ�]앳:�$ᝉ[���8���O�9�<����ik�Zi��mj6`��m�:f�4�$5�!��W�@f�2Zi}�������^�:ƤLm;���OJ���:C_q��Q��86A.��5����)�
,����]�AcN���)��>�~!���EO*��F�U%��$_�!�&�f��Z�%�z2�)%�-�Wm!'P��ީ%PœĶn��!۝b���H.i/�Lq����MVi�s���+b��u]��2���s�鉾MW��JU�eز�Ч��9\�-��0�lO7�k��2�C�J�m˦B����&�"�+��`�@[M���ҝLִu�h�Ai;�cz��&ⲉF'D+�̡L���=�yk�J��|$ΩL�8�,ێ��ϑn:�; ��D�h�#��g0 st��1���G���r�?}w*Jm+��L����Xc�(L��)��G���-�Dz�o��B�~�#&�X���!az��?{��8���{���nz���B5Ӎ�R�Gb'�LIm�N��8O���ʉ�ĉ�'Y�b��f�%FPo;쐘[�fB��`�;`>Ǐ8���ʭQ��ֽ�y��u���������<~%��~��?��)��'M��t������?�������>�|�#�Ñ�G�?x��[G?�X���k�bB�?�,L��!Y�0)�#TD�3�4�S(�x8F�[1�TȨ�ٖ�1BY��D3�(����?|9���O�8������?���/�>��q��0�X�w��?����B�ꁿy?���wl��^��9@��}��=D�&����a��"?������p1��
 -�\�X�M7s�h�|lh�XJ!�^�dX���tλ�^._(�t�Ytr[x��B|誆����]��Uŵfd#��X'�)�;#�$Ll�]҄Ыυ^�z�z����g����%��hu��*�PL�ϙc�^���آ9кB�n&h�.ř�h!�)��� ;nٙP�	f8��5��<3���U�l&��:3��i&;0�p�l�^"wg��A5�/8Ug�h������ș�.�Au�A�x^����v�2;�tM1�D.]�S��&�]&�Y	?7gJ�X���dWʶ�f���E,OR(C[k�I:
cik~��D���6Yf��e�г%=���B��;�NR2���uR��ME�\: �4ivGajV�k�E�>췻���&F�-ZUi�_Lz�V�L]�:���cQ�\��259��q]n���ifډ�ɚ�*��4���F�N��lܤ����ON��"rH�-D+z	]��o���?���D�
�DD�
�DD�
�DD�
�DD�
�DDv./a�]��R�&o��$���+���s�nV�b��-q*�m`Z1>\l��^�Ί�BUNΗ�=wQ=x(��V=�=�S=Q3e5� ���X3u;������m/��t����44g��qφ5Ҩ��Vo���(VM}�):!�Ҵz�`j���nMM��k��͑�&���q��M�O�1���q:�$$V河e-G�Z8������[���P�pn^�~2tj��pd�%b���d�4s:Sf�İ^���2�Q���y����3V˦���%s��*7ʹI+��X����v;>�E�w	�y�P��׷�p�z���Q�-��7�^{�6���X^lu���%�{c�+���y/n߂��M��9̏4��|x��k�#��>@�|��uj����_��Y}y3�F�5������Q�{����#W���x������?x��C�=x�W����e�������D]e�Lu��"�%�[[:__��O�t���qb��[f�,,g����Bnc5��t%r��/�[tL��.�ؔ�5�)�8���BA��Ri��e�3+�!0�	𘅐j�Rf�'R�)����8�$z$F���٩��� ��Ա:����ۢ������q�4�0�G��em�HwT~�����D:gK�(��P-KuW"i�r�L�΁�i����F��0M�B҂�v
*g�&���vT��N�+Ǒ�!%G��/�z�4�Vi��_ҧȚ��dS4�p�J�5e��גM\��
��J-��r����&Z����B,#�#4s��lG��P�5�1f�|/F[����ɂ�t�����J��C��ʅz��� L3.���i���������û�?�i '�t�5��A���G��*&\cE.$��E��-�l��F�3�~�z��J�˸�ܖ�]vG��ߣ�N�,�/�oV�i!y=�����thٓ]�&�Ƭ#i�L��'uq��4��pXR���_U�R]&�la��h��A#�[������Q5�룍,M���٬��;T�B�iʜm(��6Omf�1�ɏ�Nu0�Q���Dj>�h��q��=?��tB��L���t�ɴ���KV��ߥizڪE�J�QQҩj_,�c.]���j��@:o\j^,��tX1M���~<��\�n����J�.�Oc8F��9����g7����J�Ȋ@�,V�D����F�c2rW
	[V��d��HFf�v�<�ڏr�#!iBe����U&���T�H�v�U&E`λ
��y�V(��0T(WZ���Ni�<���S�:�b.���\\��U":kJ|������4:V�gQ�12x����Q��i��t�"�ew4�m
�j�
%R�����1S8.MI����,t�34U �{
1o��/����!y=��݌Z�2x'�&��'�J�n�t����� 	k��ұ��d�2*1fi^ǦҠi
57
K���lX[��F�+�X-�]�L�]Z٥���e>�٥���n^!³�_&�2��]ȳ�	y�آEE7&��U,p�f|���ς�\e�Ouq1Vo!o�#m�ey��#�nI]*��o!�?���y���-��G�%����A�<;|�|��0*��ʶ��x���7�+�Rx��1� %� d-�uFVE�0�Gdz�|��<+�S�?qN'p���J_����gqhY�(���2����>�?�C�^�E�eV������.��� �Ș_����0*���!�����^�h��^p�����Q�'AVm��wr��z��!���_v���;��Hw�a2�J҃ci"���q�!�w �i��=.gD�	����sdl����~�����������FU�kr~t�z� ��OW�=�[�g��"�[����E�U��Ui����8�Ѯ���j�����zz���,�.ِ���~x4.���6��Bz��GKZ�q���6b`�`m�OX�eq@�L btE�.T�e���4��@hgXＱIàe1�:�uA���\:	y#�wGSMKg�A`�S�
�_���՜���/��Wh5��Y-L|H8�4�?����w�п Μ����Egz�c�����[[�>�@P�*�2������Y����j�Y �@�X+�E�OZQ=�zUX��UX���ŶB�dG�KF���X[�Y��2����ڥ!t��|E���D���!ˀ��6`��e2.<���In%�m���Ö:���`qd�(p��բv�Wr9�|��B���?V6g}a{��u]�a�a�;��k�#���U �v]l*t�뒟% �<��	^ ��t�z�X��c�z:t�%> ����B�4XZ�z�.�dp��!��}�S,��̡̍��l�	�l�P8�@R��/O�pq��eW׀��5�^D����l����eu�.6����'JZ�J�D� �uep�mc[J� �T��(��Ap�`�8�$��Tro_@�����I�f_ưJ�@���\�1��>�K��d�N�&�@�mo˽�'��6�nw�)F�9ư�+ �
�1�)� �A{䢶�
��MP��?9	�z�� �Y0����X]��`m�3 	�^U�X�(�<(�e��ف4W����j��d`�g}���M�;�� d��ݴ�yj�v�,�0�I���}��n��G�����@ 땉*iְ�UW{�qNV�NñhP`���C�\l����{�����ǖ�7n�Kq�b�m�W�վ�"D�[�j1����Jֺm[͇7�Մ�8<uf��ɉ�ef2��`uXSuH�0O�i��5��cVǕ��(�������~82�m��1����s�b�JR�/�9������hwH[h�Ά�P�NPp����:����C�0G��#7�-�.7ԀO��GH>Źu��!?޵#|Y���5|_�?7>��qseW��'#�f�O2���H`�!C|B|� �Ԗm�숹a�JL���@f߆gu�:A3E>~��@d�g�b�Н�94��`�+V�"�-K[U��,��e��ǳ��F�]�z�O��٧c劆N���ڑB��!�j��$#1B�Ȑ"��n��6.Gڸ$͐�����f;FI�pT�J:��� j�w��1��b�Y�ϜX>�U�>i?��m��XO���!�Ŏ�&̮��,nV%��)5�M,�"�$�naRL�$�
ǔ��JHj� ���f2S��(I�&&��i��9�?�f���	���e��t=Eo�wnI��uG�,���̾'�������;���x��1x!��,W��:�e�"�9����e��Jsڹ8_�,ͲE�Tz�A�
�07��ėNL��g�������=�����%�������g�㱫r�HW[]�c�����*���vdg28�AGc����OZhG5��&����ZgZ�A�F[F{߸��m��&Sw�ֲ������C0ۭnΐ������~�a��$���Bz�� �$�M��9��A��}<E��x�]�y��rr=kE8�l>�g�gӡ:?AQܳFg��L��m�T��',	?�(���#^��.�Mx���76?���r%1��&��Y����`���Fg�K�덮��} ���zjמ���6π{̲Z�MZeK"-r�O�i�.q�� �)�\�?�+�S,���˝ 7b*��_(�z~[<=
�<qfޙ|֖4]�����E��`б���#��u��;�_C���Yt7�����u�e�Џ�n�_��ee�e�l�ap�Q���!	 �\�ح��|���]!yw�8���G,sV.f�&6�B�@GEg��7�:��������M��⿄I,r����t�����m�x�C��N�酯��������~X�}�W��7�o�������^>��ޒn6����������T� ���^�O�ئ�'#���Gڗ��?/�$p���M����|�����@����%<�<�<мP4���7J���G��u�����e�)rL�v�m�b�HT�-��1���-E�Z�Ho)T��C�	5#���dR�LY���N���?D����!��^�����y��f���u8���4u�W��9��w�i.���J~^�q��SI�zN��\SD�\�>#��Bd��d���i5ZV{x�-q#$-��V?~:)��I�R�t�T��bʬ&��xw�j�ű?����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g����?:|��G:��<��<�����p�?{�֝(�m����1Z=��&"�"���= �����&��;ڝT�teͧ��JJ��\s�5��B-��`��?JA�_�A�_�������O�� ����?�V�:��v���C�o)x��7������)u�ޜe��~���!�-�\���,*��t!�����O�gv?��!z[����u����g�+�'�J�|����m�Y�8FO�].��Zh����v��f���.����$�4��sՑ�U�
�|��1G�vc�#��2��͏�2p��7Rs������'�#{���_m�L���^>���ۮ�C�󄤏�:N���f9��[�o�>��n�\9��0��H�#'�]QE#�:�����MiRh�C$��x8�G���ʆ叩O۽�~���4�eĜ��0����iP����P��� 
@5���k�Z�?��+C��R��F-���O8��]
 �	� �	򟪭��?�_����������_[�Ղ����
��Ԋ�����:��0�_ޜ��/������O�}�'{~F�f��>�$�o��oe����\׿���;�u���z��~��vR�!O|����p4�+=��{s;X��{T���.ѡU7��5�5r��
j�cb�I�f��3�7v~���І���SY����y�ϟ�z�y'@�y>מK�� ����i�#�>�{����Lu�kd�������Β�7�����|�O��`��TTTA->�{����Ùk��0d/WLt�aC͑u6U9��R\2ԇkcb���������?�_���[��l��B(�+ ��_[�Ձ��W�/����:��t�cL0��i��ؔb)�d)��8?DC�g}&�  h£� '� %:�����3~u��G��P���_���]W[�b!�7[M�F�$c���;�k�kǼ�h��m�+�K��ɲSks$�/�C��d�9��S�̻�n9>��c�I��!�َ��,�cIr�}����6#*R����z�6���u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿃a��A���(b"9��ͧ�,�;9�,\wPV�%�[�'w	�'Ũߌ�8gt�K���Es��r+D���2BQF�Dr�V�ʅ��а��:��,�L�G5�i�.��{Q��?�oE���?��v��k�o@�`��:����������Z�4`���c�;�G����[��-.�/�����#r����c�{�09�O����颒�������[�A�\���g� @���3 �?�هg \�j�W���T��! o����YB�o6���Њd�/ѥ��!�F�)h�\��6˒�Xx#2�.��yy�`(����N<�{Qo�n���z�A�D��@ߍ���p��{z��� �i	�.\ꁝ�-�">~�z�Ƿ�Q��8$�Ŋ��
��T�5�=��e�h�.F��9ׅ���+w��/5."����Ox]6EUj��;��&;=t�@hL&Z[���LR�$�g��L�E����"䚡���H��j�N�69�o��G'�������h�_�E�:�?�|��H�e������E����z?�A1���:�?�>����)(��!ӯ�(��0��i������C�?��C���O��W�R��y>My��$�2So��!��yM�\Ƞ,͆��O��Ax�OY.$��h/���OC��G�(�J����u{�aY��CM�s��*���O���sc;$���Ĥ�_k ��4��g�*ȅ�lT�E�6{l�d�&�^��ݸ�����G�!���\yFm�qp�;ډ��]%�-��}/�p�������S
>���U?K�ߡ�����&0���@-�����a��$����tC�{��_5�_�:��U�����~���	����'h���������o ~��6���h��MA9'c&N��ʼ���J�%޻�˸1G~f����3���V6��y>2G��7��ǝj�Eޜ�V�vLLY�,[&�#c��6ZP{Z�#���ڛ�r4dVg6�4^kyS+�)�q7�%ְ5ӧ���Y�rma�BW�I��r����mG�;ƹ������
�t���ަk+T��ۡb��c�C�I�;�OeG�.;�j�d��4"��ַ'!�zG���|�6I�Bk3r�!w��H�,J����9O�V"����:�,d<��}��"�1ǩ��Z�e��:迋ڃ�+B9��w�+��������c�V�r���:���i��J���7���7��A�}��ۯ2� j	�������C��:���O_�PԢ���K�P������_�����j����Q�e�������C�~���(����'��/u�E�����������P5������8��*T��Q1����+������RP��p�
��_9�S����RP/��p��Q��h�	�� � ����#?�Z�?�������P��!�����j������I���ZH�C��(�����R ��� ��� ���?��P�m�W���e��C8D٨E�� �����R ��� ���Pm��@�A�c)����������_[�Ղ����8��Ԋ�a��tԡ����� ��0�������P��=��2P����>مP�W ���������p�Cy��c�E�h����@�˅���ـ#q"���N=4 H4�0��8c<��H�b��}�;��E���1��+���@^*��h��V�+�K���S*(h�]�ӌPTͻ]AK�&/}q{���qh(���jIaP4s���y~�;����Tw�E��F1$��*i�a��ås6ԙj�B��q%���h�$����!�|Sr�Զ�p
�<����ݓ����p�����P�����o������P�����P���\���_�/�:�?���W���ЩSc߳�Vc��Ⱦѝ�b{џ��/[X��?��^�?;\�2�&�k��n7W��� ���E�C�Qx�N-u�t&���b>IO
��ou��#��(��i�Y��2e@��^���w�;��%�����#������u������ �_���_����j�ЀU����a�����|���zO��7�'t�!!�����f�8�Bd���ke�Z�=k����Wp,���u �?"�:�ej͆t\r[��ړԏ�6F"S�ߎb��M���1��ht��#-Dڂ^�E��3"3�s܍�,�A���LW���v��啾f�=]:�:�o:-!ׅ�{a'DrK�����#o.�p�o7���q(H>��]'�u��,b�{����Ѳ�e���eST���w�����8��>�Su�5�Cd}�ܙu8p��t5>��xJ`��%*6���}c��x��1�[bٜmR�ٚ��}w~����4ܽ���?��E����3�������?��/u��0�A�'������?%���WmQ���q�'Q��/u�����$�(���s=!ӣ~(���1��y���(N��W���[���{��n�f���A�8�;�{�~ׁ�}�W��$޺����fi�+ώ�t�Q�^�
����?Y~�G���Y~�w�������_[��.D7�rp�.���5��sl���m!
^�VU��ꂐ_�Ά0�a��i#�WV_F����en'+�2�Ō��p�蚖�rѰS�[�51����b�r�d8W�U��1��]�����{�-Z���{r߼ɭ���\�\�&��k^��7�y�f���n���{b*Ef,��t'��h�vS�^��MnF�c�mR�E��i�,=Roۯ\��h� �ϻ��
XDv(�?0j:�͏�ܩ���©K�F�FB�4=!�N���\���,PWnJ��l�n0⬞��ɿ��wC-�u7��ߒP��c|
�i��|f�b$�q3"����$p3��Q����$��G0>P��h�Ma���P���~����`�������f|���~�|���n2��[oq;'��S�l��]!|����+V+�G��U����{�ٟ������������:�?�!�������?85F��M������A������nq�������g�=;���0:23��Yp��yv��_��^��z����1�o�m����j�!���ƺ�ܼ������~��|?���V�
��f�HwR�[��>9:jSn��5���v#^�}7��͋k?�T��'��3v6*��V'�մ3��~�G}���<��<_.ֱ�7��wfJC6f�)ɖW��Y���d>��ɲ�5����������z=�P;3�rܻ�(J�M3[/�<@��O���*E3S�a͹�	��*l��Mw�.:d3P���ܝUf���}����G�?��[
J��S�AH�,�3ǯ���|E1a8�}��<�c���]0e1
�p��<����'���������������_�M�S��O}9q�$\i�9�v����7O������e�U� �-��������~��c��2P�wQ{���W���{��_8᱖ �����!��:����1��������w�?�C�_
������������TUgm�nWf��,:����/�ptA��?t_���*����Gim�o!
ȷ�@�%[&tir6�ِ�gc�\S���=�r�ֹB>ں�u����+��忧�N���;�'5�m���_��I�:�<�<䡧Nn�"ؾ�޺��@@Q����v'��L:3i6ק*i�A�-|�Z{���J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ����  � 
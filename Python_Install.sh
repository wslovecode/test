
#!/bin/bash
#作者：王帅
#日期：2020.09.12

#是否切换到root模式
echo -e "第一次执行脚本：输入用户密码进入root模式后，请重新执行脚本，例如：
bash Python_Install.sh
后面再执行该脚本：该部分选否，继续执行后面内容
"
echo "是否进入root模式"
select r in "是" "否" "退出"
do
	case $r in
		"是")
			su root
			break
			;;
		"否")
			echo "已进入root模式才可选否，否则会安装出错。"
			break
			;;
		"退出")
			exit
			break
			;;
	esac
done

#是否提升当前操作用户权限
echo "是否提升当前操作用户的权限，若选否可能会导致安装失败。"
echo "提示：请输入选项前编号数字进行选择。如输入1表示选择是，输入2表示选择否，输入3表示退出安装"
select num1 in "是" "否" "退出"
do
	case $num1 in
		"是")
			#提升当前操作用户的权限			
			chmod 777 /etc/sudoers                                              					
			echo -e "注意：输入用户密码进入root模式后输入以下命令提升用户权限：             	                                         		
vim /etc/sudoers   #按i进入插入模式                                	
在Allow root to run any commands anywhere的行下添加以下2行内容:         
root	ALL=(ALL)	ALL                                      		
username	ALL=(ALL)	ALL     #username指当前操作用户             
按Esc并输入: wq!                                                        		                                          		
chmod 440 /etc/sudoers #恢复/etc/sudoers的访问权限为440，可选执行      		                      		
bash Python_Install.sh  #重新执行脚本，该部分选否，继续执行后面内容   			
				 "	
			exit						
			break
			;;
		"否")
			echo "没有提升当前操作用户的权限，可能会导致安装失败。"
			break
			;;
		"退出")
			exit 
			;;
		*)
			echo "输入错误，请重新输入！"
	esac

done

#是否安装zlib相关工具包
#在CentOS以及其他Linux系统，如果缺少Zlib相关依赖包，
#可能会导致安装包安装错误“zipimport.ZiplmportError:can't decompress data”
echo "是否安装zlib的相关工具包，若选否可能会导致安装失败"
select num2 in "是" "否" "退出"
do
	case $num2 in
		"是")
			#安装zlib的相关工具包
			yum -y install zlib*
			if [[ $? -eq 0 ]];then
				echo "成功安装zlib的相关工具包。"
			else
				echo "外网连接失败请配置网络，或缺失yum、python"
				exit
			fi
			break
			;;
		"否")
			echo "没有安装zlib的相关工具包，可能会导致安装失败。"
			break
			;;
		"退出")
			exit 
			;;
		*)
			echo "输入错误，请重新输入！"
	esac

done

#当前Linux系统是否为Ubuntu
echo "当前Linux系统是Ubuntu吗？" 
select answer in "是" "否" "退出"
do
	case $answer in
		"是")
			sudo apt-get update
			sudo apt-get install python3.8
			python --version			
			python3 --version
			if [[ $? -eq 0 ]];then
				echo "安装成功"
			else
				echo "安装失败，当前Linux系统可能不是Ubuntu，或者外网连接失败，请配置网络。"
			fi
			exit		
			;;
		"否")
			echo "继续执行后面的脚本，在非Ubuntu系统上安装最新版python"
			break
			;;
		"退出")
			exit
			;;
		*)
			echo "输入错误，请重新输入！"
	esac
done

#是否卸载已安装python
python --version
if [[ $? -eq 0 ]];then
	echo "当前Linux已安装python,是否卸载已安装的python？请慎重选择！！！"
	select num3 in "是" "否" "退出"
	do
		case $num3 in
			"是")
				#卸载已安装的python				
				#强制删除已安装程序及其关联
				rpm -qa | grep python
				#rpm -qa | grep python | xargs rpm -ev --allmatches --nodeps				
				#删除所有残余文件 ##xargs，允许你对输出执行其他某些命令				
				#whereis python  | xargs rm -frv				
				#验证删除，返回无结果
				whereis python				
				python --version
				if [[ $? -eq 0 ]];then					 	
					echo "原有版本python卸载失败,是否继续安装新版本python?"
					select num4 in "是" "否，退出"
					do
						case $num4 in
							"是")
								echo "继续安装新版本python。"
								break
								;;
							"否，退出")
								exit
								;;
							"*")
								echo "输入错误，请重新输入！"
						esac
					done					 
				else					
					echo "卸载成功"
				fi	
				break
				;;
			"否")
				echo "不卸载已安装的python，继续安装新版本python。"
				break
				;;
			"退出")
				exit 
				;;
			*)
				echo "输入错误，请重新输入！"
		esac

	done	
	
else
	echo "当前Linux未安装python，继续安装新版本python。"
fi

#选择离线安装还是在线安装
echo "请选择安装方式：离线安装或在线安装"
select install_item in "离线安装" "在线安装" "退出"
do
	case $install_item in
	
		"离线安装")
			#获取安装包路径
			read -p "请输入python安装压缩包所在的路径，例如/home/ws/桌面，>>" package_path
			cd $package_path	
			#解压安装包
			read -p "请输入python安装压缩包的名称(不包含文件扩展名)，例如Python-3.8.5，>>" install_name			
			tar -zxvf ${install_name}.tgz
			#设置安装路径
			cd ./${install_name}
			read -p "请输入python安装路径，如/usr/local  >>" install_path
			./configure  --prefix=${install_path}
			#编译和安装
			make && sudo make install
			#验证是否安装成功
			python3 --version
			if [[ $? -eq 0 ]];then
				echo "安装成功"		
				
				#是否设置python命令为调用最新安装的python开发环境
				read -n1 -p "是否设置python命令为调用最新安装的python开发环境,请输入Y/N" environment
				case $environment in
					Y | y)					
						python --version					
						if [[ $? -eq 0 ]];then
							#取消调用原来版本python开发环境的python命令
							sudo unlink /usr/bin/python					
						fi
						#设置python命令为调用最新安装的python开发环境
						sudo ln -s ${install_path}/bin/python3.8 /usr/bin/python					
						python --version
						if [[ $? -eq 0 ]];then
							echo "设置python命令为调用最新安装的python开发环境成功"															
						else
							echo "设置python命令为调用最新安装的python开发环境失败。"							
						fi	
						break
						;;
					N | n)
						echo "python命令仍为调用原来的python开发环境"
						break
						;;
					*)
						echo "输入错误，请重新输入！"					
				esac					
				#是否删除python压缩安装包、解压安装包
				read -n1 -p "是否删除python压缩安装包、解压安装包？[Y/N]" delete_package
				case $delete_package in
					Y | y)									
						#删除下载的压缩安装包、解压安装包	
						cd ${package_path}
						rm -rf Python-${Pversion}.tgz
						rm -rf Python-${Pversion}		
						echo "已删除python压缩安装包、解压安装包"
						break
						;;
					N | n)
						echo "仍保留python压缩安装包、解压安装包"
						break
						;;
					*)
						echo "输入错误，请重新输入！"
				esac				
			else
				echo "安装失败"
			fi
			break
			;;				

		"在线安装")
			#输入需要安装的python最新版本号
			echo "请确认已连接外网，否则会在线安装失败！"
			read -n5 -p "请输入需要安装的Python最新版本号，如3.8.5:" Pversion		
			#在线下载压缩安装包	
			echo "开始下载python安装包"
			wget https://www.python.org/ftp/python/${Pversion}/Python-${Pversion}.tgz
			#判断外网是否连接正常
			
			#解压安装包
			tar -zxvf Python-${Pversion}.tgz
			#设置安装路径
			cd ./Python-${Pversion}
			read -p "请输入python安装路径，如/usr/local  >>" install_path
			./configure  --prefix=${install_path}
			#编译和安装
			make && sudo make install 
			#验证是否安装成功		
			python3 --version
			if [[ $? -eq 0 ]];then				
				echo "安装成功"		
				
				#是否设置python命令为调用最新安装的python开发环境
				read -n1 -p "是否设置python命令为调用最新安装的python开发环境,请输入Y/N" environment
				case $environment in
					Y | y)					
						python --version					
						if [[ $? -eq 0 ]];then
							#取消调用原来版本python开发环境的python命令
							sudo unlink /usr/bin/python					
						fi
						#设置python命令为调用最新安装的python开发环境
						sudo ln -s ${install_path}/bin/python3.8 /usr/bin/python					
						python --version
						if [[ $? -eq 0 ]];then
							echo "设置python命令为调用最新安装的python开发环境成功"										
						else
							echo "设置python命令为调用最新安装的python开发环境失败。"
						fi	
						break
						;;
					N | n)
						echo "python命令仍为调用原来的python开发环境"
						break
						;;
					*)
						echo "输入错误，请重新输入！"					
				esac	
				#是否删除python压缩安装包、解压安装包
				read -n1 -p "是否删除python压缩安装包、解压安装包？[Y/N]" delete_package
				case ${delete_package} in
					Y | y)									
						#删除下载的压缩安装包、解压安装包	
						pwd
						ls
						cd ..  #回到上一级目录										
						rm -rf Python-${Pversion}.tgz
						rm -rf Python-${Pversion}		
						echo "已删除python压缩安装包、解压安装包"
						break
						;;
					N | n)
						echo "仍保留python压缩安装包、解压安装包"
						break
						;;
					*)
						echo "输入错误，请重新输入！"
				esac				
			else
				echo "安装失败"
			fi																				
				
			break
			;;		
			
		"退出")
			exit
			;;
			
		*)
			echo "输入错误，请重新输入！"			
	esac
done

#执行结束
exit 0







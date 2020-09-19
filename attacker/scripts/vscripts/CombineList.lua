local m = {}

m.recipes={
	--{"resultName","item1",{"item2",3}}  第一个是成品名字，后面的是合成材料。如果需要多个材料，则写成table的形式，table的第一个元素是材料名字，第二个是材料数量
	{"item_A_clone","{item_A,2}"},--中攻击
	{"item_A_clone_clone","{item_A_clone,2}"},--大攻击
	{"item_C_clone","{item_C,2}",},--中护甲
	{"item_C_clone_clone","{item_C_clone,2}"},--大护甲
	{"item_D_clone","item_D,2"},--中血量
	{"item_D_clone_clone","item_D_clone,2"},--大血量
	{"item_B_clone","item_B,2"},--中属性
	{"item_B_clone_clone","item_B_clone,2"},--大属性
}


local function init()
	RegisterEventListener("zxj_combine_list_get",Dynamic_Wrap(m,"SendRecipesToClient"))
end

print("liebiao")
init()
return m
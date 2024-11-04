import bpy


    
 #   bpy.context.active_object.pose.bones["Bone."+formatted_number]
 #   bpy.ops.pose.constraint_add(type='COPY_TRANSFORMS')
#    bpy.context.object.pose.bones["Bone."+formatted_number].constraints["Copy Transforms"].target = bpy.data.objects["Armature"]
   # bpy.context.object.pose.bones["Bone."+ formatted_number].constraints["Copy Transforms"].subtarget = "Bone."+formatted_number


bones = bpy.context.object.pose.bones
i = 0 
for bone in bones:
    
    bpy.context.object.data.bones.active = bone.bone
    bone.bone.select = True
    bpy.ops.pose.constraint_add(type='COPY_TRANSFORMS')
    print(bones[i].name)
    bpy.context.object.pose.bones[bones[i].name].constraints["Copy Transforms"].target = bpy.data.objects["Armature"]
    bpy.context.object.pose.bones[bones[i].name].constraints["Copy Transforms"].subtarget = bones[i].name
    i += 1




#selection_names = bpy.context.active_object.pose.bones

#for i in range(len(selection_names)):

#    print(selection_names[12].name)
#    bpy.data.objects["Armature"].data.bones[selection_names[12].name].select = True
#    bpy.ops.pose.constraint_add(type='COPY_TRANSFORMS')
#    bpy.data.objects["Armature"].data.bones[selection_names[12].name].select = False

#print("Constraints added to all bones.")
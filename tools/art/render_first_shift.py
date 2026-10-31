"""Original mechanical sprite source. Run with Blender 4.3+ --background --python.
No providers, downloads or paid APIs. Orthographic Cycles, 3 source pixels/world unit.
Raw renders/receipts go to --output (default /tmp/rustbelt-art); never edit painted sources.
"""
import bpy, math, json, os, sys, time, random
from pathlib import Path
from mathutils import Vector
from bpy_extras.object_utils import world_to_camera_view
ARGS=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
OUT=Path(ARGS[ARGS.index('--output')+1]) if '--output' in ARGS else Path('/tmp/rustbelt-art')
OUT.mkdir(parents=True,exist_ok=True)
ROOT=Path(__file__).resolve().parents[2]
PPU=3
receipts={}

def mat(name,color,metal=0,rough=.4,texture=False,emission=0):
 m=bpy.data.materials.get(name)
 if m: return m
 m=bpy.data.materials.new(name);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 if emission:
  p.inputs['Emission Color'].default_value=(*color,1);p.inputs['Emission Strength'].default_value=emission
 if texture:
  n=m.node_tree.nodes.new('ShaderNodeTexNoise');n.inputs['Scale'].default_value=48;n.inputs['Detail'].default_value=3
  bump=m.node_tree.nodes.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.15;bump.inputs['Distance'].default_value=.025
  m.node_tree.links.new(n.outputs['Fac'],bump.inputs['Height']);m.node_tree.links.new(bump.outputs['Normal'],p.inputs['Normal'])
  ramp=m.node_tree.nodes.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].position=.2;ramp.color_ramp.elements[0].color=(*(c*.65 for c in color),1);ramp.color_ramp.elements[1].position=.8;ramp.color_ramp.elements[1].color=(*color,1)
  m.node_tree.links.new(n.outputs['Fac'],ramp.inputs[0]);m.node_tree.links.new(ramp.outputs[0],p.inputs['Base Color'])
 return m
TEAL=mat('enamel petrol',(.052,.16,.155),.65,.3,True)
EDGE=mat('edge burnished',(.24,.34,.3),.75,.28)
DARK=mat('gunmetal',(.024,.046,.053),.65,.38,True)
BRASS=mat('aged brass',(.57,.33,.09),.78,.27,True)
GOLD=mat('safety enamel',(.88,.53,.10),.42,.36,True)
RUBBER=mat('rubber',(.02,.026,.026),.05,.78,True)
SILVER=mat('machined steel',(.49,.61,.59),.85,.21)
CREAM=mat('ivory enamel',(.7,.73,.57),.22,.4)
WOOD=mat('oiled timber',(.24,.106,.037),0,.65,True)
GLASS=mat('amber lens',(.95,.39,.055),.35,.19,emission=2)
GREEN=mat('mint lens',(.22,.82,.55),.2,.16,emission=1.8)
WHITE=mat('gauge face',(.76,.8,.67),.18,.38)

TREAD=mat('oxidized steel grating',(.075,.12,.115),.55,.52,True)

def painted_wear(material,filename,amount=.7,offset=0):
 nodes=material.node_tree.nodes;links=material.node_tree.links
 image=nodes.new('ShaderNodeTexImage');image.image=bpy.data.images.load(str(ROOT/'assets/art/painted'/filename),check_existing=True);image.projection='BOX';image.projection_blend=.12
 coord=nodes.new('ShaderNodeTexCoord');mapping=nodes.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY_ADD';mapping.inputs[1].default_value=(.2,.2,.22);mapping.inputs[2].default_value=(.12+offset,.23,.13)
 links.new(coord.outputs['Generated'],mapping.inputs[0]);links.new(mapping.outputs[0],image.inputs[0])
 p=nodes.get('Principled BSDF');old=p.inputs['Base Color'].links[0].from_socket if p.inputs['Base Color'].is_linked else None
 blend=nodes.new('ShaderNodeMixRGB');blend.blend_type='MIX';blend.inputs[0].default_value=amount
 if old: links.new(old,blend.inputs[1])
 else: blend.inputs[1].default_value=p.inputs['Base Color'].default_value
 links.new(image.outputs['Color'],blend.inputs[2]);links.new(blend.outputs[0],p.inputs['Base Color'])

painted_wear(TEAL,'weathered_steel.png',.22)
painted_wear(TREAD,'weathered_steel.png',.3)

# Every mesh has real thickness, edge bevels and split, weighted normals.
def finish(o,material,bevel=0):
 o.data.materials.append(material)
 if bevel:
  m=o.modifiers.new('machined edges','BEVEL');m.width=bevel;m.segments=3
  n=o.modifiers.new('weighted normals','WEIGHTED_NORMAL');n.keep_sharp=True
 return o

def box(at,size,material,bevel=.025):
 bpy.ops.mesh.primitive_cube_add(size=1,location=at);o=bpy.context.object;o.dimensions=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 return finish(o,material,bevel)

def cyl(at,radius,depth,material,axis='Y',verts=48):
 bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=radius,depth=depth,location=at)
 o=bpy.context.object
 if axis=='Y': o.rotation_euler[0]=math.pi/2
 if axis=='X': o.rotation_euler[1]=math.pi/2
 for p in o.data.polygons: p.use_smooth=True
 return finish(o,material,min(.018,radius*.12))

def bolt(at,r=.035,axis='Y'):
 return cyl(at,r,.035,BRASS,axis,6)

def bar(a,b,r,material):
 mid=(Vector(a)+Vector(b))*.5;d=Vector(b)-Vector(a)
 o=cyl(mid,r,d.length,material,'Z',16);o.rotation_euler=d.to_track_quat('Z','Y').to_euler();return o

def pipe(points,r,material):
 c=bpy.data.curves.new('bent tube','CURVE');c.dimensions='3D';c.bevel_depth=r;c.bevel_resolution=3
 s=c.splines.new('BEZIER');s.bezier_points.add(len(points)-1)
 for p,at in zip(s.bezier_points,points):p.co=at;p.handle_left_type='AUTO';p.handle_right_type='AUTO'
 o=bpy.data.objects.new('tube',c);bpy.context.collection.objects.link(o);o.data.materials.append(material);return o

def gauge(at,r=.15):
 cyl(at,r,.09,BRASS)
 x,y,z=at;cyl((x,y-.06,z),r*.83,.025,WHITE)
 for a in range(0,300,30):
  a=math.radians(a-60);bar((x+math.cos(a)*r*.64,y-.082,z+math.sin(a)*r*.64),(x+math.cos(a)*r*.74,y-.082,z+math.sin(a)*r*.74),.009,DARK)
 bar((x,y-.09,z),(x+r*.5,y-.09,z+r*.25),.012,DARK)

def deck(moving=False):
 box((0,0,-.17),(4,.85,.34),TEAL)
 # Recessed web, bevelled perimeter and grating across the actual landing plane.
 box((0,-.46,-.19),(3.88,.09,.18),DARK,.012)
 for x in [-1.9,1.9]:box((x,0,-.17),(.16,1.0,.4),GOLD if moving else BRASS)
 for z in [-.06,-.33]:box((0,-.52,z),(4,.08,.07),EDGE,.012)
 for i in range(14):
  x=-1.83+i*.28
  box((x,0,.015),(.21,.92,.055),TREAD,.008)
  for y in [-.23,.03,.29]:box((x,y,.045),(.12,.07,.014),DARK,.003)
 for i in range(7):
  x=-1.65+i*.54
  bar((x,-.52,-.28),(x+.4,-.52,-.08),.025,BRASS)
  bolt((x,-.58,-.18),.035)
 if moving:
  box((0,-.56,-.19),(3.6,.035,.17),GOLD,.008)
  for x in [-1.6,-1.2,-.8,-.4,0,.4,.8,1.2,1.6]:
   b=box((x,-.589,-.19),(.12,.025,.21),DARK,.004);b.rotation_euler[1]=-.55
  for x in [-1.75,1.75]:cyl((x,-.59,-.16),.085,.07,DARK);cyl((x,-.64,-.16),.05,.025,GREEN)
  box((0,.05,-.46),(1.5,.68,.28),DARK)
  for x in [-.4,.4]:cyl((x,-.4,-.48),.16,.12,TEAL);bolt((x,-.48,-.48),.06)
 else:
  for x in [-1.6,1.6]:
   bar((x,-.2,-.32),(x*.76,-.1,-.73),.04,DARK)
   bar((x*.76,-.1,-.73),(x*.55,0,-.32),.035,BRASS)

def support():
 box((0,.05,-2),(.25,.3,4),TEAL)
 for x in [-.2,.2]:box((x,0,-2),(.07,.4,4),BRASS,.01)
 for z in [0,-1,-2,-3,-4]:
  box((0,-.15,z),(.5,.12,.1),EDGE,.015)
  for x in [-.13,.13]:bolt((x,-.23,z),.025)

def beam():
 box((0,0,-.3),(6,.42,.6),TEAL)
 for z in [-.04,-.56]:box((0,-.24,z),(6,.15,.1),BRASS)
 box((0,-.24,-.3),(5.85,.025,.35),DARK)
 for i in range(12):
  x=-2.8+i*.48
  bar((x,-.3,-.51),(x+.38,-.3,-.09),.04,EDGE)
  for z in [-.09,-.51]:bolt((x,-.34,z),.03)

def piston_head():
 box((0,0,.25),(1.65,.62,.5),DARK,.09)
 box((0,-.34,.26),(1.52,.12,.39),GOLD,.025)
 for x in [-.59,-.23,.13,.49]:
  o=box((x,-.407,.26),(.14,.018,.41),DARK,.005);o.rotation_euler[1]=-.55
 box((0,0,.015),(1.74,.75,.07),SILVER,.018)
 for x in [-.7,.7]:
  box((x,.04,.5),(.2,.48,.15),TEAL)
  bolt((x,-.427,.26),.05)
 cyl((0,0,.6),.18,.25,SILVER,'Z')
 for y in [-.18,.18]:bar((-.58,y,.48),(-.58,y,.73),.055,SILVER);bar((.58,y,.48),(.58,y,.73),.055,SILVER)

def hydraulic():
 cyl((0,0,-.55),.32,1.1,TEAL,'Z')
 for z in [-.04,-1.06]:
  cyl((0,0,z),.39,.12,BRASS,'Z')
  for x in [-.24,.24]:bolt((x,-.31,z),.035)
 for x in [-.25,.25]:bar((x,-.22,-.05),(x,-.22,-1.05),.035,SILVER)
 gauge((0,-.35,-.5),.15)
 pipe([(.3,.12,-.2),(.55,.13,-.2),(.55,.13,-.9),(.3,.12,-.9)],.045,BRASS)

def crate():
 box((0,0,.5),(1,.75,1),DARK,.025)
 for i in range(5):
  x=-.4+i*.2
  box((x,-.4,.5),(.18,.06,.91),WOOD,.015)
  box((x,0,1.01),(.18,.72,.055),WOOD,.01)
 for z in [.08,.91]:box((0,-.45,z),(1.06,.07,.1),TEAL)
 for x in [-.46,.46]:
  box((x,-.45,.5),(.09,.07,1),BRASS,.015)
  for z in [.09,.9]:bolt((x,-.5,z),.028)
 bar((-.4,-.46,.14),(.4,-.46,.86),.045,BRASS)
 box((0,-.47,.56),(.32,.035,.22),CREAM,.01)

def console():
 box((0,0,.055),(.74,.6,.11),DARK)
 box((0,0,.35),(.42,.37,.6),TEAL)
 box((0,0,.84),(.73,.56,.5),TEAL,.08)
 box((0,-.31,.88),(.59,.06,.32),DARK,.025)
 gauge((-.13,-.37,.93),.12)
 for x,m in [(.12,GREEN),(.25,GLASS)]:cyl((x,-.37,.89),.043,.035,m)
 bar((.1,0,1.08),(.1,-.26,1.4),.035,SILVER);cyl((.1,-.27,1.4),.075,.15,DARK,'X')
 for x in [-.28,.28]:bolt((x,-.355,.7),.028)

def battery():
 box((0,0,.4),(.62,.42,.8),TEAL,.07)
 for z in [.07,.72]:box((0,-.24,z),(.66,.08,.12),BRASS)
 box((0,-.23,.4),(.42,.07,.42),DARK)
 for z in [.24,.4,.56]:box((0,-.28,z),(.32,.035,.08),GREEN,.015)
 for x in [-.18,.18]:cyl((x,0,.86),.07,.12,BRASS,'Z')
 bar((-.2,0,.87),(-.2,0,1),.035,DARK);bar((-.2,0,1),(.2,0,1),.035,DARK);bar((.2,0,1),(.2,0,.87),.035,DARK)

def lantern():
 cyl((0,0,0),.29,.11,DARK,'Z')
 cyl((0,0,.32),.22,.55,GLASS,'Z')
 for x,y in [(-.2,-.2),(-.2,.2),(.2,-.2),(.2,.2)]:bar((x,y,.03),(x*.8,y*.8,.6),.035,BRASS)
 for z in [.02,.6]:cyl((0,0,z),.3,.07,BRASS,'Z')
 bpy.ops.mesh.primitive_cone_add(vertices=48,radius1=.34,radius2=.16,depth=.18,location=(0,0,.73));finish(bpy.context.object,TEAL,.02)
 cyl((0,0,.87),.06,.13,BRASS,'Z')
 # A local glow is composited in-engine, never baked into the alpha margin.

def station():
 box((0,0,.06),(.7,.5,.12),DARK)
 box((0,.06,.65),(.15,.16,1.3),TEAL)
 box((0,0,1.27),(.7,.32,.7),TEAL,.09)
 box((0,-.19,1.27),(.55,.06,.55),CREAM,.025)
 box((0,-.23,1.27),(.11,.03,.38),TEAL,.01);box((0,-.23,1.27),(.38,.03,.11),TEAL,.01)
 for x in [-.25,.25]:
  for z in [1.03,1.51]:bolt((x,-.235,z),.027)
 cyl((0,0,1.7),.16,.16,GREEN,'Z')

# An original patrol model. Front wheels are separate sprites to retain real rotation.
def patrol():
 box((0,0,.49),(1.7,.92,.26),DARK,.08)
 for x in [-.63,.63]:
  cyl((x,.42,.27),.26,.2,RUBBER)
  cyl((x,.54,.27),.17,.04,BRASS)
 box((0,0,.85),(1.66,.91,.65),TEAL,.15)
 box((0,0,1.18),(1.2,.75,.1),GOLD,.04)
 box((.12,-.49,.85),(.9,.06,.38),GOLD,.045)
 box((-.56,-.49,.85),(.3,.075,.4),DARK,.04)
 for z in [.72,.81,.9,.99]:box((-.56,-.54,z),(.23,.03,.035),SILVER,.006)
 for x in [-.25,.49]:
  for z in [.7,1]:bolt((x,-.545,z),.027)
 box((0,-.52,.53),(1.85,.17,.12),EDGE,.035)
 box((.92,0,.88),(.2,.55,.52),DARK,.08)
 cyl((.61,-.59,1.03),.14,.13,BRASS)
 cyl((.61,-.67,1.03),.105,.035,GLASS)
 cyl((.61,-.7,1.03),.047,.01,CREAM)
 # Auxiliary copper cooling system, exhaust, and power cable.
 cyl((-.67,.06,1.42),.09,.55,DARK,'Z');cyl((-.67,.06,1.7),.14,.07,BRASS,'Z')
 pipe([(-.7,-.41,.55),(-.88,-.41,.7),(-.88,-.4,1),(-.69,-.39,1.12)],.035,BRASS)
 box((-.05,.15,1.32),(.48,.35,.2),DARK)
 for x in [-.19,-.1,0,.1]:box((x,.1,1.44),(.025,.4,.1),SILVER,.008)
 for x in [-.64,.64]:bar((x,-.15,.5),(x,-.55,.29),.07,SILVER)

def wheel():
 cyl((0,0,0),.29,.22,RUBBER)
 for a in range(0,360,20):
  a=math.radians(a);b=box((math.cos(a)*.28,-.015,math.sin(a)*.28),(.095,.24,.045),DARK,.009);b.rotation_euler[1]=-a
 cyl((0,-.13,0),.22,.05,BRASS)
 cyl((0,-.165,0),.17,.025,DARK)
 for a in range(0,360,60):
  a=math.radians(a);bar((math.cos(a)*.05,-.19,math.sin(a)*.05),(math.cos(a)*.15,-.19,math.sin(a)*.15),.027,SILVER)
 cyl((0,-.195,0),.065,.05,BRASS);bolt((0,-.23,0),.035)

def pump():
 box((0,0,.07),(2.25,1.2,.14),DARK)
 cyl((-.2,0,.65),.48,1.7,TEAL,'X')
 for x in [-.9,-.7,.35,.55]:cyl((x,0,.65),.52,.1,BRASS,'X')
 for z in [.32,.46,.6,.74,.88]:box((-.25,-.47,z),(1.25,.07,.045),DARK,.009)
 gauge((.64,-.43,.92),.2)
 pipe([(.7,0,.6),(1,0,.6),(1,.1,1.2),(.6,.1,1.4)],.13,BRASS)
 pipe([(-.9,.1,.6),(-1.15,.1,.6),(-1.2,.1,.2)],.14,TEAL)
 cyl((.38,-.44,1.4),.23,.04,BRASS)
 for a in range(0,360,90):
  a=math.radians(a);bar((.38,-.44,1.4),(.38+math.cos(a)*.21,-.44,1.4+math.sin(a)*.21),.024,DARK)
 bar((.38,-.44,1.4),(.38,0,1.35),.035,SILVER)

def salvage():
 cyl((0,0,0),.23,.13,BRASS)
 cyl((0,-.08,0),.15,.025,DARK)
 cyl((0,-.1,0),.08,.03,GREEN)
 for angle in range(0,360,45):
  a=math.radians(angle);o=box((math.cos(a)*.24,0,math.sin(a)*.24),(.1,.15,.1),BRASS,.018);o.rotation_euler[1]=-a

def stone_arch():
 rng=random.Random(603)
 stones=[mat('limestone '+str(i),(.28+i*.012,.29+i*.011,.22+i*.009),0,.82,True) for i in range(6)]
 for i,m in enumerate(stones): painted_wear(m,'viaduct_stone.png',.82,i*.07)
 moss=mat('moss velvet',(.095,.18,.059),0,.95)
 leaf=mat('ivy leaf',(.16,.27,.085),0,.66)
 # The arch is actual voussoir geometry, with individual beveled blocks.
 for x in [-2.7,2.7]:
  for row in range(8):
   box((x,0,-.9-row*.78),(.58,1.1,.75),rng.choice(stones),.035)
 center_z=-4.9
 # Continuous stone backing closes the small gaps above the voussoirs.
 for j in range(24):
  x1=-2.7+j*5.4/24;x2=x1+5.4/24
  z1=center_z+math.sqrt(max(0,2.7**2-x1*x1));z2=center_z+math.sqrt(max(0,2.7**2-x2*x2))
  pts=[(x1,-.49,-.35),(x2,-.49,-.35),(x2,-.49,z2),(x1,-.49,z1),(x1,.5,-.35),(x2,.5,-.35),(x2,.5,z2),(x1,.5,z1)]
  mesh=bpy.data.meshes.new('spandrel');mesh.from_pydata(pts,[],[(0,1,2,3),(7,6,5,4),(0,4,5,1),(3,2,6,7)]);mesh.update()
  o=bpy.data.objects.new('spandrel',mesh);bpy.context.collection.objects.link(o);finish(o,stones[0])
 for j in range(15):
  a=math.pi*.025+j*math.pi*.95/15;b=math.pi*.025+(j+1)*math.pi*.95/15
  gap=.012;a+=gap;b-=gap
  pts=[]
  for y in [-.55,.55]:
   for angle,r in [(a,2.12),(b,2.12),(b,2.7),(a,2.7)]:
    pts.append((math.cos(angle)*r,y,center_z+math.sin(angle)*r))
  faces=[(0,1,2,3),(7,6,5,4),(0,4,5,1),(1,5,6,2),(2,6,7,3),(3,7,4,0)]
  mesh=bpy.data.meshes.new('arch stone');mesh.from_pydata(pts,[],faces);mesh.update()
  o=bpy.data.objects.new('voussoir',mesh);bpy.context.collection.objects.link(o);finish(o,rng.choice(stones),.025)
 # Staggered courses fill only above the arch opening.
 for row in range(5):
  z=-.7-row*.62
  for col in range(8):
   x=-2.62+col*.75+(0.12 if row%2 else 0)
   if x>.4 and x>2.75: continue
   ceiling=center_z+math.sqrt(max(0,2.68**2-x*x))
   if z-.28 < ceiling: continue
   box((x,0,z),(.71,1.08,.57),rng.choice(stones),.035)
 for i in range(8):
  box((-2.62+i*.75,0,-.18),(.735,1.22,.34),stones[4],.035)
 # Patches of irregular moss; no regular grid of foliage.
 for side in [-1,1]:
  for i in range(30):
   z=-.25-rng.random()*2.6;x=side*(2.7+rng.uniform(-.2,.16))
   bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=rng.uniform(.045,.11),location=(x,-.59,z))
   o=bpy.context.object;o.scale=(1.3,.25,.7);finish(o,moss)
  for j in range(14):
   z=-.3-j*.14;x=side*(2.3+math.sin(j*.7)*.13)
   bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.075,location=(x,-.6,z))
   o=bpy.context.object;o.scale=(1.4,.2,.55);o.rotation_euler[1]=(-.6 if j%2 else .6);finish(o,leaf)

def render(name,builder,w,h,anchor=(0,0,0),target_z=0):
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 builder()
 s=bpy.context.scene
 bpy.ops.object.camera_add(location=(0,-10,target_z+4.2));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,target_z))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=max(w,h)/40;cam.data.lens=50;s.camera=cam
 for pos,power,size,col in [((-3,-4,7),680,4,(1,.82,.58)),((4,-1,3),360,4,(.53,.77,1)),((1,3,5),900,3,(1,.75,.42))]:
  bpy.ops.object.light_add(type='AREA',location=pos);l=bpy.context.object;l.data.energy=power;l.data.shape='DISK';l.data.size=size;l.data.color=col;l.rotation_euler=(Vector((0,0,target_z))-l.location).to_track_quat('-Z','Y').to_euler()
 s.render.engine='CYCLES';s.cycles.samples=48;s.cycles.use_denoising=False;s.cycles.max_bounces=5;s.cycles.transparent_max_bounces=4
 s.world.use_nodes=True;s.world.node_tree.nodes.get('Background').inputs['Color'].default_value=(.23,.32,.39,1);s.world.node_tree.nodes.get('Background').inputs['Strength'].default_value=.4
 s.render.resolution_x=round(w*PPU);s.render.resolution_y=round(h*PPU);s.render.resolution_percentage=100;s.render.film_transparent=True;s.render.image_settings.file_format='PNG';s.render.image_settings.color_mode='RGBA';s.render.image_settings.color_depth='8';s.render.filepath=str(OUT/(name+'.png'))
 s.view_settings.view_transform='AgX';s.view_settings.look='AgX - Medium High Contrast'
 uv=world_to_camera_view(s,cam,Vector(anchor));start=time.time();bpy.ops.render.render(write_still=True)
 receipts[name]={'file':name+'.png','world_size':[w,h],'anchor':[round(uv.x*w,4),round((1-uv.y)*h,4)],'pixels_per_unit':PPU,'render_seconds':round(time.time()-start,2)}
 (OUT/'sprites.json').write_text(json.dumps(receipts,indent=2)+'\n')
 print('ASSET_DONE',name,receipts[name],flush=True)

JOBS=[
 ('catwalk',lambda:deck(False),160,64,(0,-.5,0),-.3),
 ('shuttle',lambda:deck(True),160,64,(0,-.5,0),-.3),
 ('support',support,28,180,(0,0,0),-2),
 ('gantry',beam,240,48,(0,-.25,0),-.3),
 ('piston_head',piston_head,80,52,(0,-.36,0),.35),
 ('hydraulic',hydraulic,52,76,(0,-.34,0),-.55),
 ('crate',crate,48,64,(0,-.43,0),.5),
 ('console',console,48,80,(0,-.3,0),.7),
 ('battery',battery,36,52,(0,-.25,0),.5),
 ('lantern',lantern,40,52,(0,-.24,0),.42),
 ('checkpoint',station,42,88,(0,-.2,0),.8),
 ('patrol',patrol,104,104,(0,-.4,0),.85),
 ('wheel',wheel,28,32,(0,-.2,0),0),
 ('pump',pump,120,96,(0,-.5,0),.7),
 ('stone_arch',stone_arch,240,340,(0,-.6,0),-3.6),
 ('salvage',salvage,28,28,(0,0,0),0),
]
only=ARGS[ARGS.index('--only')+1] if '--only' in ARGS else None
for job in JOBS:
 if only is None or job[0]==only:render(*job)

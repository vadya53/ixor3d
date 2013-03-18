//
//  entity.h
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "x3dmath.h"
#import "ogles.h"
#import "brush.h"
#import <vector>
#import <string>
#import "surface.h"
#import <algorithm>
#import "loaders.h"
#import "collision.h"
#import "meshcollider.h"
#import "IWorld.h"
#import <map>
#import "textureatlas.h"

enum xEntType
{
	ENTITY_NODE,
	ENTITY_CAMERA,
	ENTITY_LIGHT,
	ENTITY_PSYSTEM,
	ENTITY_TERRAIN,
	ENTITY_BONE,
	ENTITY_SPRITE
};

class xEntity;
class xBone;
class xChannel;

struct xEntityCollision
{
	xEntity    * with;
	xVector      coords;
	xCollision   collision;
};

typedef std::vector<int> IntArray;
typedef std::vector<float> FloatArray;

class xEntity
{
private:
	struct InstanceData
	{
		bool update;
		int  offset;
	};
protected:
	xVector                            _position;
	xVector                            _scale;
	xQuaternion                        _rotation;
	std::string                        _name;
	const char                       * _nameBuff;
	xTransform                         _worldTransform;
	bool                               _needUpdate;
	xEntity                          * _parent;
	bool                               _visible;
	xBrush                             _masterBrush;
	std::vector<xSurface*>             _surfaces;
	std::vector<xEntity*>              _childs;
	std::vector<xEntity*>              _copies;
	xEntity                          * _copiedFrom;
	xEntType                           _type;
	int                                _order;
	bool                               _autoFade;
	float                              _fadeNear;
	float                              _fadeFar;
	xBone                            * _rootBone;
	int                                _pickMode;
	int                                _collideType;
	std::vector<xEntityCollision*>     _collisions;
	xTransform                         _prevTransform;
	xVector                            _velocity;
	xVector                            _collideRadii;
	xBox                               _collideBox;
	xMeshCollider                    * _collider;
	std::vector<xChannel*>             _channels;
	// physics
	bool                               _needSyncBody;
	IBody                            * _physBody;
	float                            * _trimeshVB;
	int                              * _trimeshIB;
	// single mesh
	bool                               _isSingleMesh;
	xEntity                          * _singleMesh;
	std::vector<xEntity*>              _instances;
	std::map<xEntity*, InstanceData>   _updateMap;
	xTextureAtlas                    * _atlas;
	int                                _atlasFlags;
	// for MD2 animation
	MD2Loader::MD2Frame              * _md2Frames;
	std::vector<MD2Loader::MD2Frame*>  _md2Sequences;
	float                              _md2Time, _md2LocalTime, _md2Speed;
	int                                _md2Mode, _md2Dest;
	bool                               _md2Updated, _md2Cloned;
	// tweening
	xVector                            _capturedPosition;
	xVector                            _capturedScale;
	xQuaternion                        _capturedRotate;
	float                              _capturedAlpha;
	bool                               _captured;
	void                             * _userData;
	int                                _alphaFunc;
	float                              _alphaRef;
private:
	void MakeMesh(LoaderNode& node, TexturesArray& textures, MaterialsArray& materials, bool anim);
	void MergeHierarhy(xEntity * parent);
	int ExtractAnimationSetFromFile(LoaderNode * rootNode);
	void Pick(xVector & position, xVector & direction);
	xMeshCollider * GetCollider();
	void UpdateEmittedChannels();
	void InitBody();
	xBox GetMeshBox();
	float GetMeshRadius();
	void PushSurfaces(FloatArray * vertices);
	void PushSurfaces(IntArray * indices, int offset);
	void GetVB();
	void GetIB();
	int GetVBSize();
	int GetIBSize();
	xQuaternion MakeQuaternion(float x, float y, float z, float w);
	void ResetSingleSurface();
	void UpdateSingleSurface();
	void UpdateMD2Mesh();
	void UpdateMD2Animation(float deltaTime);
	int ExtractMD2AnimationSet(int startFrame, int endFrame, int setID);
	bool TrianglesIntersect(xVector v0, xVector v1, xVector v2, xVector u0, xVector u1, xVector u2);
	bool CoplanarIntersect(xVector n, xVector v0, xVector v1, xVector v2, xVector u0, xVector u1, xVector u2);
	void RebuildMesh(float time);
	bool IntersectTriangle(const xVector & position, const xVector & direction, xVector & v0, xVector & v1, xVector & v2, float * distance);
	bool IntersectBox(xVector & position, xVector & direction, float * distance);
public:
	xEntity();
	~xEntity();
	void Release();
	xTransform GetWorldTransform();
	void UpdateWorldTransform();
	void SetWorldMatrix();
	void SetPosition(float x, float y, float z, bool global);
	void Move(float x, float y, float z, bool global);
	void Translate(float x, float y, float z);
	xQuaternion GetQuaternion(bool global);
	void SetQuaternion(xQuaternion quat, bool global);
	void SetRotation(float pitch, float yaw, float roll, bool global);
	void Turn(float pitch, float yaw, float roll, bool global);
	void SetScale(float x, float y, float z, bool global);
	xVector GetPosition(bool global);
	xVector GetRotation(bool global);
	xVector GetScale(bool global);
	void SetName(const char * name);
	const char * GetName();
	bool IsVisible();
	void Show();
	void Hide();
	bool InView(xCamera * camera);
	xBrush * GetBrush();
	xSurface * CreateSurface(xBrush * brush);
	void AddSurface(xSurface * newSurface);
	int CountSurfaces();
	xSurface * GetSurface(int index);
	xSurface * FindSurface(xBrush * brush);
	void SetParent(xEntity * entity);
	xEntity * GetParent();
	void AddChild(xEntity * entity);
	void DeleteChild(xEntity * entity);
	int CountChilds();
	xEntity * GetChild(int index);
	xEntity * FindChild(const char * name);
	void CreateCube();
	void CreateSphere(int segments);
	void CreateCyllinder(int segments, bool solid);
	void CreateCone(int segments, bool solid);
	void AddMesh(xEntity * other);
	void FlipMesh();
	xEntity * Clone(xEntity * parent, bool cloneGeom);
	void ApplyBrush(xBrush * brush, bool single);
	void PositionMesh(float x, float y, float z);
	void RotateMesh(float pitch, float yaw, float roll);
	void ScaleMesh(float x, float y, float z);
	void GenerateNormals();
	xBox GetBoundingBox();
	xVector GetBoundingSphereCenter();
	float GetBoundingSphereRadius();
	float GetMeshWidth();
	float GetMeshHeight();
	float GetMeshDepth();
	void FitMesh(float x, float y, float z, float width, float height, float depth, bool uniform);
	void SetColor(int red, int gree, int blue);
	xVector GetColor();
	void SetAlpha(float alpha);
	float GetAlpha();
	void SetShininess(float shininess);
	float GetShininess();
	void SetBlendMode(int mode);
	int GetBlendMode();
	void SetFXFlags(int fx);
	int GetFXFlags();
	void SetTexture(int index, xTexture * texture, int frame);
	xTexture * GetTexture(int index);
	void Draw();
	bool LoadMesh(const char * path);
	bool LoadAnimMesh(const char * path);
	xEntType GetType();
	void SetOrder(int order);
	int GetOrder();
	void SetAutoFade(float nearValue, float farValue);
	void ForceUpdate();
	bool IsSkinned();
	void UpdateSkin();
	void Animate(int mode, float speed, int setID, float smooth);
	bool Animated();
	int AnimationSet();
	float AnimationTime();
	float AnimationSpeed();
	float AnimationLength();
	void SetAnimationTime(float value);
	void SetAnimationSpeed(float value);
	int ExtractAnimationSet(int startFrame, int endFrame, int setID);
	int LoadAnimationSet(const char * path);
	void SetPickMode(int mode);
	int GetPickMode();
	void LinePick(xVector & position, xVector & direction);
	void Reset();
	void SetCollisionRadii(xVector radii);
	void SetCollisionBox(xBox box);
	void SetCollisionType(int type);
	const std::vector<xEntityCollision*> & GetCollisions();
	void ClearCollisions();
	int GetCollisionType();
	xVector GetCollisionRadii();
	xBox GetCollisionBox();
	void SavePervTransform();
	void AddCollision(xEntityCollision * c);
	bool Collide(const x3DLine &line, float radius, xCollision * currColl, const xTransform &t);
	xTransform GetWorldTransformPrev();
	void AddChannel(xChannel * channel);
	bool MeshesIntersect(xEntity * other);
	// physics methods
	IBody * GetPhysBody();
	void AddDummyShape();
	void AddBoxShape(float mass, float width, float height, float depth);
	void AddSphereShape(float mass, float redius);
	void AddCapsuleShape(float mass, float radius, float height);
	void AddConeShape(float mass, float radius, float height);
	void AddCylinderShape(float mass, float width, float height, float depth);
	void AddTriMeshShape(float mass);
	void AddHullShape(float mass);
	void SyncBodyTransform();
	void SyncEntityTransform();
	void ApplyCentralForce(float x, float y, float z);
	void ApplyCentralImpulse(float x, float y, float z);
	void ApplyTorque(float x, float y, float z);
	void ApplyTorqueImpulse(float x, float y, float z);
	void ApplyForce(float x, float y, float z, float pointx, float pointy, float pointz);
	void ApplyImpulse(float x, float y, float z, float pointx, float pointy, float pointz);
	void SetDamping(float linear, float angular);
	float GetLinearDamping();
	float GetAngularDamping();
	void SetFriction(float friction);
	float GetFriction();
	void SetRestitution(float restitution);
	float GetRestitution();
	void ReleaseForces();
	xVector GetForce();
	xVector GetTorque();
	void FreeShapes();
	int GetContactsNumber();
	xVector GetContactPoint(int index);
	xVector GetContactNormal(int index);
	float GetContactDistance(int index);
	xEntity * GetContactSecondBody(int index);
	// single mesh functions
	void MakeSingleSurface();
	void AddInstance(xEntity * instance);
	void RemoveInstance(xEntity * instance);
	// md2 meshes
	void UpdateMD2(float deltaTime);
	// tweening
	void Capture();
	void ApplyTweening(float tween);
	void SetUserData(void * data);
	void * GetUserData();
	void SetAlphaFunc(int func);
	void SetAlphaRef(float reference);
	int GetAlphaFunc();
	float GetAlphaRef();
	void SetAtlasFlags(int flags);
};
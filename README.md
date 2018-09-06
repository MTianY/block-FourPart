# block 的循环引用

## 一.循环引用产生的原因分析

首先看一段产生循环引用的代码:

- `TYPerson` 对象中定义了2个属性

```objc
typedef void(^Test1Block)(void);
@interface TYPerson : NSObject
@property (nonatomic, copy) Test1Block test1Block;
@property (nonatomic, assign) int age;
@end
```

- 下面代码的写法则会产生循环引用.
    - 打印只有 `-------`
    - 并没有执行 person 的 dealloc, 说明 person 没有被释放掉 

```objc
int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        {
            TYPerson *person = [TYPerson new];
            person.age = 20;
            person.test1Block = ^{
                NSLog(@"age = %d",person.age);
            };
        }
        
        NSLog(@"-------");
        
    }

    return 0;
}
```

循环引用的原因分析

- 首先看下 block 内部

```c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  TYPerson *__strong person;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, TYPerson *__strong _person, int flags=0) : person(_person) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

- 可以看到 block 内部对 person 对象是有个强引用的`TYPerson *_strong person`.
- 而看`TYPerson`.它的属性 `@property (nonatomic, copy) Test1Block test1Block;` 
    - 表明它的成员变量 `_test1Block` 会对 block 产生一个强引用.
- 所以上面循环引用产生的原因就是:
    - 首先 `TYPerson *person = [TYPerson new];`  有个 person 的指针指向 TYPerson
    - `person`的`test1Block`在堆上.`test1Block`内部有个 `TYPerson *_strong person`,block 对 person 又有个强引用.
    - 而`TYPerson`的成员变量`_test1Block`又对 block 有个强引用.
    - 所以当上面的代码大括号执行完成后,`TYPerson 对 person 的强引用会断开`,但是 `block 对 person 和 person 内部的成员变量 _test1Block 对 block 的强引用还没有断开`,所以产生了循环引用
- 如下图:

![WechatIMG25](https://lh3.googleusercontent.com/-NY89OsfWV18/W5G4nMka_fI/AAAAAAAAAJk/3Kk5k-W79JkkaNo5L2UYlJTYaNpEGz7xACHMYCw/I/WechatIMG25.jpeg)



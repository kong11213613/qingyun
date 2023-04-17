package main

import (
	"flag"
	"fmt"
	"github.com/realmicro/realmicro"
	mconfig "github.com/realmicro/realmicro/config"
	"github.com/realmicro/realmicro/config/encoder/yaml"
	"github.com/realmicro/realmicro/config/reader"
	"github.com/realmicro/realmicro/config/reader/json"
	"github.com/realmicro/realmicro/config/source/file"
	"github.com/realmicro/realmicro/logger"
	mlogrus "github.com/realmicro/realmicro/logger/logrus"
	"github.com/realmicro/realmicro/registry"
	"github.com/realmicro/realmicro/registry/etcd"
	"github.com/realmicro/realmicro/wrapper/select/dc"
	"github.com/sirupsen/logrus"
	"qingyun/common/wrapper"
	"qingyun/services/chat-gpt/internal/config"
	"qingyun/services/chat-gpt/internal/logic/mobile"
	"qingyun/services/chat-gpt/internal/svc"
	chat_gpt "qingyun/services/chat-gpt/proto/mobile"
)

var configFile = flag.String("f", "etc/config.yaml", "the config file")

func main() {
	flag.Parse()
	c, _ := mconfig.NewConfig(
		mconfig.WithReader(
			json.NewReader(
				reader.WithEncoder(yaml.NewEncoder()),
			),
		),
	)
	var err error
	// load the config from a file source
	if err = c.Load(file.NewSource(
		file.WithPath(*configFile),
	)); err != nil {
		fmt.Println(err)
		return
	}
	var cfg config.Config
	if err = c.Scan(&cfg); err != nil {
		fmt.Println(err)
		return
	}

	logger.DefaultLogger = mlogrus.NewLogger(mlogrus.WithJSONFormatter(&logrus.JSONFormatter{}))
	service := realmicro.NewService(
		realmicro.Name(cfg.ServiceName),
		realmicro.Version(cfg.Version),
		realmicro.Metadata(map[string]string{
			"env":     cfg.Env,
			"project": cfg.Project,
		}),
		realmicro.Registry(etcd.NewRegistry(registry.Addrs(cfg.Hosts.Etcd.Address...))),
		realmicro.WrapHandler(wrapper.LogHandler()),
		realmicro.WrapClient(dc.NewDCWrapper, wrapper.LogCall),
	)
	service.Init()

	ctx := svc.NewServiceContext(&cfg, service)
	if err = chat_gpt.RegisterMobileChatGptServiceHandler(service.Server(), mobile.NewMobileChatGptService(ctx)); err != nil {
		if err = service.Run(); err != nil {
			panic(err)
		}
	}

}